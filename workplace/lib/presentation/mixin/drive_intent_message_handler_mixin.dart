import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';
import 'package:workplace/domain/message/workplace_intent_message.dart';
import 'package:workplace/presentation/model/drive_pick_outcome.dart';

enum _Phase { waiting, loadingPage, interactive, closed }

/// Lazy so the modal starts the request only after its error handling is live.
typedef DriveIntentLoader = Future<WorkplaceIntent> Function();

/// Shared loading/messaging lifecycle for the mobile and web Drive picker modals.
mixin DriveIntentMessageHandlerMixin<T extends StatefulWidget> on State<T> {
  late String _intentId;
  String _intentOrigin = 'null';
  Timer? _readyTimeoutTimer;

  _Phase _phase = _Phase.waiting;
  WorkplaceIntent? _resolvedIntent;
  bool _platformViewReady = false;

  bool get showSkeleton =>
      _phase == _Phase.waiting || _phase == _Phase.loadingPage;

  void _setPhase(_Phase next) {
    if (_phase == _Phase.closed || next == _phase) return;
    if (mounted) {
      setState(() => _phase = next);
    } else {
      _phase = next;
    }
  }

  String get intentOrigin => _intentOrigin;

  /// Covers silent failures like SSO blocking the page with no postMessage ever sent.
  Duration get readyTimeout => const Duration(seconds: 20);

  void startLoading(DriveIntentLoader intentLoader) {
    // Starts the deadline immediately so a platform view that never becomes
    // ready (e.g. WebView/iframe init silently failing) still times out.
    _restartReadyTimeout();
    unawaited(_loadIntent(intentLoader));
  }

  Future<void> _loadIntent(DriveIntentLoader intentLoader) async {
    try {
      final intent = await intentLoader();
      if (!mounted) return;
      _resolvedIntent = intent;
      _tryApplyIntent();
    } catch (e, s) {
      _failWith('intent loader failed', e, s);
    }
  }

  /// Single Sentry funnel for every failure path: reports the failing stage
  /// with the original exception and stack, then closes the modal.
  void _failWith(String stage, Object error, [StackTrace? stackTrace]) {
    logError(
      'driveIntent: $stage',
      exception: error,
      stackTrace: stackTrace,
    );
    _finish(DrivePickOutcomeFailed(error));
  }

  void _restartReadyTimeout() {
    _readyTimeoutTimer?.cancel();
    _readyTimeoutTimer = Timer(readyTimeout, _handleReadyTimeout);
  }

  void notifyPlatformViewReady({bool viewRecreated = false}) {
    _platformViewReady = true;
    if (viewRecreated && _phase == _Phase.loadingPage) {
      final intent = _resolvedIntent;
      if (intent != null) {
        // A replacement iframe needs the resolved URL and a fresh deadline.
        _restartReadyTimeout();
        unawaited(_applyIntent(intent));
      }
      return;
    }
    _tryApplyIntent();
  }

  /// The intent can only be applied once: after both the intent resolved and
  /// the platform view reported ready, and before leaving [_Phase.waiting].
  bool get _canApplyIntent =>
      _resolvedIntent != null &&
      _platformViewReady &&
      _phase == _Phase.waiting;

  void _tryApplyIntent() {
    if (!_canApplyIntent) return;
    final intent = _resolvedIntent!;
    _intentId = intent.intentId;
    _intentOrigin = intent.intentUrl.scheme == 'data'
        ? 'null'
        : intent.intentUrl.origin;
    _setPhase(_Phase.loadingPage);
    unawaited(_applyIntent(intent));
  }

  Future<void> _applyIntent(WorkplaceIntent intent) async {
    try {
      await loadIntent(intent);
    } catch (e, s) {
      _failWith('loading intent into platform view failed', e, s);
    }
  }

  /// Async so platform-channel failures (e.g. WebView loadUrl) reject the
  /// returned future and are funneled instead of becoming uncaught errors.
  Future<void> loadIntent(WorkplaceIntent intent);

  /// Fails fast on a main-frame page load failure instead of waiting for
  /// [readyTimeout]. Only honored while the Drive page is loading: earlier
  /// errors cannot be ours, later ones belong to the page's error protocol.
  void notifyPageLoadFailed(Object error) {
    if (_phase != _Phase.loadingPage) {
      log('driveIntent: ignored page load failure in phase $_phase: $error');
      return;
    }
    _failWith('platform view failed to load page', error);
  }

  void _handleReadyTimeout() {
    _failWith(
      'timed out waiting for ready after $readyTimeout',
      DriveIntentTimeoutException(),
    );
  }

  /// Protocol messages only make sense while the Drive page is loaded:
  /// before that [_intentId]/[_intentOrigin] are unset, after close the
  /// outcome is already delivered.
  bool get _acceptsMessages =>
      _phase == _Phase.loadingPage || _phase == _Phase.interactive;

  void onMessage({required String raw, required String? origin}) {
    if (!_acceptsMessages) return;
    if (!_isValidOrigin(origin)) {
      log('driveIntent: dropped message from unexpected origin: $origin');
      return;
    }
    final WorkplaceIntentMessage msg;
    try {
      msg = WorkplaceIntentMessage.parse(_intentId, raw);
    } catch (_) {
      log('driveIntent: failed to parse message: $raw');
      return;
    }
    unawaited(_dispatchWorkplaceMessage(msg));
  }

  Future<void> _dispatchWorkplaceMessage(WorkplaceIntentMessage msg) async {
    try {
      await _handleWorkplaceMessage(msg);
    } catch (e, s) {
      _failWith('handling workplace message failed', e, s);
    }
  }

  bool _isValidOrigin(String? origin) {
    if (origin == null) return false;
    if (origin == _intentOrigin) return true;
    // On mobile the JS shim forwards targetOrigin as the origin arg. Data URIs
    // have opaque 'null' origin but the shim receives '*' from postMessage.
    return _intentOrigin == 'null' && origin == '*';
  }

  Future<void> _handleWorkplaceMessage(WorkplaceIntentMessage msg) async {
    switch (msg) {
      case WorkplaceIntentReadyMessage():
        log('driveIntent: ready received, sending ack');
        await sendAck();
        break;
      case WorkplaceIntentReadyToUseMessage():
        log('driveIntent: readyToUse received, hiding loading');
        _readyTimeoutTimer?.cancel();
        _setPhase(_Phase.interactive);
        break;
      case WorkplaceIntentDoneMessage():
        log('driveIntent: done received, docs: ${msg.documents.map((d) => '{id:${d.id}, name:${d.name}, size:${d.size}, mimeType:${d.mimeType}').join(', ')}');
        _finish(DrivePickOutcomePicked(msg.documents));
        break;
      case WorkplaceIntentErrorMessage():
        _failWith('drive page reported error', DriveIntentErrorException());
        break;
      case WorkplaceIntentCancelMessage():
        log('driveIntent: cancel received, closing modal');
        _finish(const DrivePickOutcomeCancelled());
        break;
      case WorkplaceIntentUnknownMessage():
        log('driveIntent: unknown message type ${msg.type}, discarded');
        break;
    }
  }

  void cancel() => _finish(const DrivePickOutcomeCancelled());

  @override
  void dispose() {
    _readyTimeoutTimer?.cancel();
    super.dispose();
  }

  void _finish(DrivePickOutcome outcome) {
    if (_phase == _Phase.closed) return;
    _setPhase(_Phase.closed);
    _readyTimeoutTimer?.cancel();
    // Once closed, the timeout is cancelled and _finish won't run again, so
    // the pop must happen even if a subclass hook throws — otherwise the
    // modal hangs with no fallback. Each hook is guarded independently so a
    // throwing onCleanup still runs onFinished, and neither escapes into the
    // unawaited futures that call _finish as an unobserved async error.
    try {
      onCleanup();
    } catch (e, s) {
      logError('driveIntent: onCleanup failed', exception: e, stackTrace: s);
    }
    try {
      onFinished(outcome);
    } catch (e, s) {
      logError('driveIntent: onFinished failed', exception: e, stackTrace: s);
    }
    // Guarded like the hooks above: _finish runs from Timer/unawaited paths, so
    // a throwing pop must not escape as an uncaught async error.
    try {
      if (mounted) Navigator.of(context).pop(outcome);
    } catch (e, s) {
      logError('driveIntent: pop failed', exception: e, stackTrace: s);
    }
  }

  /// Async so ack-delivery failures (e.g. evaluateJavascript) reject the
  /// returned future and are funneled instead of becoming uncaught errors.
  Future<void> sendAck();

  void onCleanup() {}

  @protected
  void onFinished(DrivePickOutcome outcome) {}

  @visibleForTesting
  void cancelReadyTimeoutForTesting() => _readyTimeoutTimer?.cancel();
}
