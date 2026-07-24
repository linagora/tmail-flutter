import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';
import 'package:workplace/domain/message/workplace_intent_message.dart';
import 'package:workplace/presentation/model/drive_pick_outcome.dart';

enum _Phase { waiting, loadingPage, interactive, closed }

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

  void startLoading(Future<WorkplaceIntent> intentFuture) {
    // Starts the deadline immediately so a platform view that never becomes
    // ready (e.g. WebView/iframe init silently failing) still times out.
    _readyTimeoutTimer?.cancel();
    _readyTimeoutTimer = Timer(readyTimeout, _handleReadyTimeout);
    intentFuture
        .then((intent) {
          if (!mounted) return;
          _resolvedIntent = intent;
          _tryApplyIntent();
        })
        .catchError((Object e) {
          _finish(DrivePickOutcomeFailed(e));
        });
  }

  void notifyPlatformViewReady() {
    _platformViewReady = true;
    _tryApplyIntent();
  }

  void _tryApplyIntent() {
    final intent = _resolvedIntent;
    if (intent == null || !_platformViewReady || _phase != _Phase.waiting) {
      return;
    }
    _intentId = intent.intentId;
    _intentOrigin = intent.intentUrl.scheme == 'data'
        ? 'null'
        : intent.intentUrl.origin;
    _setPhase(_Phase.loadingPage);
    loadIntent(intent);
  }

  void loadIntent(WorkplaceIntent intent);

  void _handleReadyTimeout() {
    log('driveIntent: timed out waiting for ready after $readyTimeout');
    _finish(DrivePickOutcomeFailed(DriveIntentTimeoutException()));
  }

  void onMessage({required String raw, required String? origin}) {
    if (_phase.index < _Phase.loadingPage.index) return;
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
    _handleWorkplaceMessage(msg);
  }

  bool _isValidOrigin(String? origin) {
    if (origin == null) return false;
    if (origin == _intentOrigin) return true;
    // On mobile the JS shim forwards targetOrigin as the origin arg. Data URIs
    // have opaque 'null' origin but the shim receives '*' from postMessage.
    return _intentOrigin == 'null' && origin == '*';
  }

  void _handleWorkplaceMessage(WorkplaceIntentMessage msg) {
    switch (msg) {
      case WorkplaceIntentReadyMessage():
        log('driveIntent: ready received, sending ack');
        sendAck();
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
        log('driveIntent: error received, closing modal');
        _finish(DrivePickOutcomeFailed(DriveIntentErrorException()));
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
    onCleanup();
    onFinished(outcome);
    if (mounted) Navigator.of(context).pop(outcome);
  }

  void sendAck();

  void onCleanup() {}

  @protected
  void onFinished(DrivePickOutcome outcome) {}

  @visibleForTesting
  void cancelReadyTimeoutForTesting() => _readyTimeoutTimer?.cancel();
}
