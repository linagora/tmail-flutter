import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:model/model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_auto_save_notifier.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_cache_providers.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

extension HandleMobileAutoSaveExtension on ComposerController {
  static const _periodicSnapshotInterval = Duration(seconds: 30);
  static const _getContentTimeout = Duration(seconds: 2);
  // 300ms guard filters AppLifecycleState.inactive from system overlays
  // (permission dialogs, incoming calls) that resolve quickly.
  static const _inactiveGuardDelay = Duration(milliseconds: 300);

  void initMobileAutoSave() {
    mobileAutoSaveLifecycleListener ??= AppLifecycleListener(
      onStateChange: _onLifecycleStateChanged,
    );
    _startPeriodicContentSnapshot();
    log('HandleMobileAutoSaveExtension::initMobileAutoSave: initialized');
  }

  void disposeMobileAutoSave() {
    inactiveGuardTimer?.cancel();
    inactiveGuardTimer = null;
    periodicSnapshotTimer?.cancel();
    periodicSnapshotTimer = null;
    mobileAutoSaveLifecycleListener?.dispose();
    mobileAutoSaveLifecycleListener = null;
  }

  // Only sets the flag in notifier state; the actual Hive clean-close write is
  // deferred to onClose so it runs after all timer/lifecycle teardown.
  // No-op on non-Android: composerAutoSaveProvider is only initialised on
  // Android, so reading it on other platforms would create an orphaned family
  // entry that is never invalidated (memory leak).
  void markCleanClose() {
    if (!PlatformInfo.isAndroid) return;
    _autoSaveNotifier()?.setCleanClose();
    log('HandleMobileAutoSaveExtension::markCleanClose: flagged');
  }

  ComposerAutoSaveNotifier? _autoSaveNotifier() {
    final id = autoSaveComposerId;
    if (id == null) return null;
    return appProviderContainer.read(composerAutoSaveProvider(id).notifier);
  }

  Future<String?> _fetchEditorContent() async {
    try {
      return await htmlEditorApi?.getText().timeout(_getContentTimeout);
    } catch (e) {
      log('HandleMobileAutoSaveExtension::_fetchEditorContent: error=$e');
      return null;
    }
  }

  void _startPeriodicContentSnapshot() {
    periodicSnapshotTimer?.cancel();
    periodicSnapshotTimer = Timer.periodic(_periodicSnapshotInterval, (_) {
      unawaited(_updateLastKnownContent());
    });
  }

  Future<void> _updateLastKnownContent() async {
    final content = await _fetchEditorContent();
    if (content != null) _autoSaveNotifier()?.updateLastKnownContent(content);
  }

  void _onLifecycleStateChanged(AppLifecycleState state) {
    log('HandleMobileAutoSaveExtension::_onLifecycleStateChanged: state=$state');
    switch (state) {
      case AppLifecycleState.inactive:
        inactiveGuardTimer?.cancel();
        inactiveGuardTimer = Timer(_inactiveGuardDelay, () {
          unawaited(_saveSnapshotToCache());
        });
        break;
      case AppLifecycleState.resumed:
        inactiveGuardTimer?.cancel();
        inactiveGuardTimer = null;
        unawaited(_restoreIfEditorBlank());
        break;
      default:
        break;
    }
  }

  Future<void> _restoreIfEditorBlank() async {
    try {
      final currentContent = await _fetchEditorContent();
      if (currentContent != null && currentContent.trim().isNotEmpty) return;

      final accountId = mailboxDashBoardController.accountId.value;
      final userName = mailboxDashBoardController.sessionCurrent?.username;
      if (accountId == null || userName == null) return;

      final cache = await _autoSaveNotifier()?.restore(accountId, userName);
      if (cache == null) return;

      log('HandleMobileAutoSaveExtension::_restoreIfEditorBlank: restoring from cache');
      final restoredHtml = cache.email?.emailContentList.asHtmlString ?? '';
      await htmlEditorApi?.setText(restoredHtml);
      // Keep the fallback snapshot in sync: if the editor dies before the next
      // periodic tick, _saveSnapshotToCache will use this restored content.
      if (restoredHtml.isNotEmpty) _autoSaveNotifier()?.updateLastKnownContent(restoredHtml);
      // Delete the stale snapshot now that its content is live in the editor.
      // The periodic timer will write a fresh snapshot on the next 30 s tick.
      unawaited(clearComposerMobileSnapshot());
    } catch (e) {
      log('HandleMobileAutoSaveExtension::_restoreIfEditorBlank: error=$e');
    }
  }

  Future<void> _refreshLastKnownContent(ComposerAutoSaveNotifier notifier) async {
    final content = await _fetchEditorContent();
    if (content != null && notifier.mounted) notifier.updateLastKnownContent(content);
  }

  Future<void> _saveSnapshotToCache() async {
    final notifier = _autoSaveNotifier();
    if (notifier == null || notifier.isCleanClose) return;

    try {
      await _refreshLastKnownContent(notifier);

      KeyboardUtils.hideSystemKeyboardMobile();

      final createEmailRequest = await buildCreateEmailRequestForAutoSave();

      if (createEmailRequest == null) {
        log('HandleMobileAutoSaveExtension::_saveSnapshotToCache: no request, skip');
        return;
      }
      final saveResult = await saveComposerCacheInteractor.execute(
        createEmailRequest: createEmailRequest,
        isPersistent: true,
      );
      saveResult.fold(
        (failure) => log('HandleMobileAutoSaveExtension::_saveSnapshotToCache: save failure=${failure.runtimeType}'),
        (_) { if (notifier.mounted) notifier.onSnapshotSaved(); },
      );

      unawaited(_saveToDraftSilently(createEmailRequest));
    } catch (e) {
      log('HandleMobileAutoSaveExtension::_saveSnapshotToCache: error=$e');
    }
  }

  void _onDraftSaveState(Either<Failure, Success> state) {
    state.fold(
      (failure) {
        // Privacy: only the type is sent — no content, subject, or recipients.
        SentryManager.instance.captureException(
          'Layer2AutoSaveDraftFailure: ${failure.runtimeType}',
          level: SentryLevel.warning,
        );
        log('HandleMobileAutoSaveExtension::_onDraftSaveState: failure=${failure.runtimeType}');
      },
      (success) {
        if (success is SaveEmailAsDraftsSuccess || success is UpdateEmailDraftsSuccess) {
          // Do NOT clear the Hive cache here: the periodic auto-save may have
          // written a newer snapshot while this JMAP call was in flight (race
          // condition on slow networks). Cleanup is handled by markCleanClose
          // (intentional close) and the 24 h TTL on ComposerPersistentCache.
          log('HandleMobileAutoSaveExtension::_onDraftSaveState: saved to server draft');
        }
      },
    );
  }

  Future<void> _saveToDraftSilently(CreateEmailRequest createEmailRequest) async {
    final notifier = _autoSaveNotifier();
    if (notifier == null || notifier.isSavingToDraftInProgress) return;

    notifier.beginDraftSave();
    try {
      await for (final state in createNewAndSaveEmailToDraftsInteractor.execute(
        createEmailRequest: createEmailRequest,
      )) {
        _onDraftSaveState(state);
      }
    } catch (e) {
      // Privacy: only the type is captured.
      SentryManager.instance.captureException(
        'Layer2AutoSaveDraftException: ${e.runtimeType}',
        level: SentryLevel.warning,
      );
      log('HandleMobileAutoSaveExtension::_saveToDraftSilently: error=${e.runtimeType}');
    } finally {
      if (notifier.mounted) notifier.endDraftSave();
    }
  }

  void _persistCleanCloseIfNeeded(String id) {
    final isCleanClose = appProviderContainer
        .read(composerAutoSaveProvider(id).notifier)
        .isCleanClose;
    if (!isCleanClose) return;
    final accountId = mailboxDashBoardController.accountId.value;
    final userName = mailboxDashBoardController.sessionCurrent?.username;
    if (accountId == null || userName == null) return;
    unawaited(appProviderContainer
        .read(markComposerLocalCacheCleanCloseProvider)
        .execute(accountId, userName));
  }

  void tearDownMobileAutoSave() {
    final id = autoSaveComposerId;
    if (id != null) _persistCleanCloseIfNeeded(id);
    try {
      disposeMobileAutoSave();
    } finally {
      if (id != null) appProviderContainer.invalidate(composerAutoSaveProvider(id));
    }
  }

  Future<void> clearComposerMobileSnapshot() {
    if (autoSaveComposerId == null) return Future.value();
    final accountId = mailboxDashBoardController.accountId.value;
    final userName = mailboxDashBoardController.sessionCurrent?.username;
    if (accountId == null || userName == null) return Future.value();
    return _autoSaveNotifier()?.clearCache(accountId, userName) ?? Future.value();
  }
}
