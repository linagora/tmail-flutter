import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:model/model.dart';
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

  // Written eagerly before navigation — process is still foreground, and
  // isCleanClose already blocks snapshot writes (no Hive write race).
  // No-op on non-Android: provider is Android-only (memory leak guard).
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

  // Updates lastKnownHtmlContent and, when foregrounded, silently saves the
  // draft to the server only if composer state changed since the last auto-save.
  // Not called from inactive: background token refresh may be killed before
  // writing the refreshed token to Hive, corrupting the account cache.
  Future<void> _periodicSaveTask() async {
    final content = await _fetchEditorContent();
    if (content != null) _autoSaveNotifier()?.updateLastKnownContent(content);

    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) return;

    final notifier = _autoSaveNotifier();
    if (notifier == null || notifier.isCleanClose) return;

    final int currentHash;
    try {
      // Reuse already-fetched content to avoid a second WebView getText() call.
      currentHash = await hashComposerStateForAutoSave(htmlContent: content).timeout(_getContentTimeout);
    } on TimeoutException {
      log('HandleMobileAutoSaveExtension::_periodicSaveTask: hash timeout, skip');
      return;
    }
    if (currentHash == lastAutoSavedToServerHash) return;

    // Don't consume the hash while a save is in flight: the in-flight save will
    // finish with older content, and the next tick must retry with the new hash.
    if (notifier.isSavingToDraftInProgress) return;

    final effectiveContent = content ?? notifier.lastKnownHtmlContent;
    final createEmailRequest = await buildCreateEmailRequestForAutoSave(
      htmlContent: effectiveContent,
    );
    if (createEmailRequest == null) {
      log('HandleMobileAutoSaveExtension::_periodicSaveTask: request is null, skip');
      return;
    }

    // Optimistic: on failure, retry is deferred until content changes.
    lastAutoSavedToServerHash = currentHash;
    unawaited(_saveToDraftSilently(createEmailRequest));
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
    // Guard against concurrent calls (editor-load and lifecycle-resumed can both fire).
    if (isRestoringFromCache) return;
    isRestoringFromCache = true;
    try {
      final payload = await _resolveRestorePayload();
      if (payload == null) return;
      // Re-check after await: user may have closed the composer during resolution.
      // isClosed: onClose() already ran (fresh notifier resets isCleanClose to false).
      // isCleanClose: markCleanClose() fired but onClose() not yet called.
      if (isClosed || _autoSaveNotifier()?.isCleanClose == true) return;
      log('HandleMobileAutoSaveExtension::restoreIfEditorBlank: restoring from cache');
      await payload.api.setText(payload.html);
      // Sync fallback so _saveSnapshotToCache has fresh content if editor
      // crashes before the next periodic tick.
      if (payload.html.isNotEmpty) _autoSaveNotifier()?.updateLastKnownContent(payload.html);
      // Content is now live in editor; remove stale Hive snapshot.
      unawaited(clearComposerMobileSnapshot());
    } catch (e) {
      log('HandleMobileAutoSaveExtension::restoreIfEditorBlank: error=$e');
    } finally {
      isRestoringFromCache = false;
    }
  }

  Future<({HtmlEditorApi api, String html})?> _resolveRestorePayload() async {
    final currentContent = await _fetchEditorContent();
    if (currentContent != null && currentContent.trim().isNotEmpty) return null;

    final accountId = mailboxDashBoardController.accountId.value;
    final userName = mailboxDashBoardController.sessionCurrent?.username;
    if (accountId == null || userName == null) return null;

    final cache = await _autoSaveNotifier()?.restore(accountId, userName);
    if (cache == null) return null;

    final api = htmlEditorApi;
    if (api == null) return null;

    return (api: api, html: cache.email?.emailContentList.asHtmlString ?? '');
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
      (failure) => log('HandleMobileAutoSaveExtension::_saveSnapshotToCache: save failure=${failure.runtimeType}'),
      (_) { if (notifier.mounted) notifier.onSnapshotSaved(); },
    );
  }

  Future<void> _saveSnapshotToCache() async {
    final notifier = _autoSaveNotifier();
    if (notifier == null || notifier.isCleanClose) return;

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
      // Re-check: markCleanClose() may have fired during the async gaps, racing
      // with _persistCleanCloseToCache() to write isCleanClose to Hive.
      if (notifier.isCleanClose) return;
      await _executeCacheSave(createEmailRequest, notifier);
      // Server save excluded: inactive path fires in background where a token
      // refresh may be terminated before writing to Hive. See _periodicSaveTask().
    } catch (e) {
      log('HandleMobileAutoSaveExtension::_saveSnapshotToCache: error=$e');
    }
  }

  void _onDraftSaveState(Either<Failure, Success> state) {
    state.fold(
      (failure) {
        // Privacy: log type only — no content, subject, or recipients.
        logError('HandleMobileAutoSaveExtension::_onDraftSaveState: failure=${failure.runtimeType}');
      },
      (success) {
        // Don't clear Hive: a newer snapshot may have been written while this
        // call was in flight. Cleanup is via markCleanClose() or the 24 h TTL.
        if (success is SaveEmailAsDraftsSuccess) {
          emailIdEditing = success.emailId;
          log('HandleMobileAutoSaveExtension::_onDraftSaveState: saved to server draft');
        } else if (success is UpdateEmailDraftsSuccess) {
          emailIdEditing = success.emailId;
          log('HandleMobileAutoSaveExtension::_onDraftSaveState: updated server draft');
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
    } catch (e, st) {
      // Privacy: log type only.
      logError(
        'HandleMobileAutoSaveExtension::_saveToDraftSilently: error=${e.runtimeType}',
        exception: e,
        stackTrace: st,
      );
    } finally {
      if (notifier.mounted) notifier.endDraftSave();
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
