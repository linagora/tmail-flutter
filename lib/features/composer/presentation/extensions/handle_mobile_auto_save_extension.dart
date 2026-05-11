import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/widgets.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_auto_save_notifier.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_cache_providers.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

extension HandleMobileAutoSaveExtension on ComposerController {
  static const _periodicSnapshotInterval = Duration(seconds: 30);
  static const _getContentTimeout = Duration(seconds: 2);
  // Filters transient inactive events (overlays, incoming calls) that resolve quickly.
  static const _inactiveGuardDelay = Duration(milliseconds: 300);

  void initMobileAutoSave() {
    if (autoSaveComposerId == null) return;
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

  // Android-only: provider is guarded against memory leaks on other platforms.
  // Called before navigation while still in foreground (no Hive write race).
  void markCleanClose() {
    if (!PlatformInfo.isAndroid) return;
    final notifier = _autoSaveNotifier();
    if (notifier == null) return;
    notifier.setCleanClose();
    _persistCleanCloseToCache();
    log('HandleMobileAutoSaveExtension::markCleanClose: flagged and persisted');
  }

  void _persistCleanCloseToCache() {
    final accountId = mailboxDashBoardController.accountId.value;
    final userName = mailboxDashBoardController.sessionCurrent?.username;
    if (accountId == null || userName == null) return;
    unawaited(appProviderContainer
        .read(markComposerLocalCacheCleanCloseProvider)
        .execute(accountId, userName));
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
      unawaited(_periodicSaveTask());
    });
  }

  Future<void> _periodicSaveTask() async {
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
        unawaited(restoreIfEditorBlank());
        break;
      default:
        break;
    }
  }

  Future<void> restoreIfEditorBlank() async {
    if (_autoSaveNotifier()?.isCleanClose == true) return;
    if (isRestoringFromCache) return;
    isRestoringFromCache = true;
    try {
      final payload = await _resolveRestorePayload();
      if (payload == null) return;
      // Re-check: user may have closed (isClosed) or navigated away (isCleanClose)
      // during the async resolution above.
      if (isClosed || _autoSaveNotifier()?.isCleanClose == true) return;
      await _applyRestoredPayload(payload);
      unawaited(clearComposerMobileSnapshot());
    } catch (e) {
      logError(
        'HandleMobileAutoSaveExtension::restoreIfEditorBlank: error=${e.runtimeType}',
      );
    } finally {
      isRestoringFromCache = false;
    }
  }

  Future<void> _applyRestoredPayload(
    ({HtmlEditorApi api, String html, EmailId? draftEmailId}) payload,
  ) async {
    log('HandleMobileAutoSaveExtension::_applyRestoredPayload: restoring from cache');
    await payload.api.setText(payload.html);
    if (payload.html.isNotEmpty) _autoSaveNotifier()?.updateLastKnownContent(payload.html);
  }

  Future<({HtmlEditorApi api, String html, EmailId? draftEmailId})?> _resolveRestorePayload() async {
    final currentContent = await _fetchEditorContent();
    if (currentContent != null && currentContent.trim().isNotEmpty) return null;

    final accountId = mailboxDashBoardController.accountId.value;
    final userName = mailboxDashBoardController.sessionCurrent?.username;
    if (accountId == null || userName == null) return null;

    final cache = await _autoSaveNotifier()?.restore(accountId, userName);
    if (cache == null) return null;

    final api = htmlEditorApi;
    if (api == null) return null;

    return (
      api: api,
      html: cache.email?.emailContentList.asHtmlString ?? '',
      draftEmailId: cache.draftEmailId,
    );
  }

  // Fresh editor content takes priority; falls back to last known (ADR-0086 Layer 1).
  String _resolveAndSyncContent(
    String? freshContent,
    ComposerAutoSaveNotifier notifier,
  ) {
    if (freshContent != null) {
      if (notifier.mounted) notifier.updateLastKnownContent(freshContent);
      return freshContent;
    }
    return notifier.lastKnownHtmlContent;
  }

  Future<void> _executeCacheSave(
    CreateEmailRequest createEmailRequest,
    ComposerAutoSaveNotifier notifier,
  ) async {
    final saveResult = await saveComposerCacheInteractor.execute(
      createEmailRequest: createEmailRequest,
      isPersistent: true,
    );
    saveResult.fold(
      (failure) => logError(
        'HandleMobileAutoSaveExtension::_saveSnapshotToCache: save failure=${failure.runtimeType}',
        exception: failure is FeatureFailure ? failure.exception : null,
      ),
      (_) { if (notifier.mounted) notifier.onSnapshotSaved(); },
    );
  }

  Future<void> _saveSnapshotToCache() async {
    final notifier = _autoSaveNotifier();
    if (notifier == null || notifier.isCleanClose) return;
    // Don't overwrite a valid snapshot while restore is reading and applying it.
    // A kill in this window would leave the cache with empty content.
    if (isRestoringFromCache) return;

    try {
      final freshContent = await _fetchEditorContent();
      final effectiveContent = _resolveAndSyncContent(freshContent, notifier);

      KeyboardUtils.hideSystemKeyboardMobile();

      final createEmailRequest = await buildCreateEmailRequestForAutoSave(
        htmlContent: effectiveContent,
      );

      if (createEmailRequest == null) {
        log('HandleMobileAutoSaveExtension::_saveSnapshotToCache: no request, skip');
        return;
      }
      // Re-check: markCleanClose() may have raced during the async gaps above.
      if (notifier.isCleanClose) return;
      await _executeCacheSave(createEmailRequest, notifier);
    } catch (e) {
      logError(
        'HandleMobileAutoSaveExtension::_saveSnapshotToCache: error=${e.runtimeType}',
      );
    }
  }

  void tearDownMobileAutoSave() {
    try {
      disposeMobileAutoSave();
    } finally {
      final id = autoSaveComposerId;
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
