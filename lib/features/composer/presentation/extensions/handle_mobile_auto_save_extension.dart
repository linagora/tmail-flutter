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
  // 300ms guard filters AppLifecycleState.inactive from system overlays
  // (permission dialogs, incoming calls) that resolve quickly.
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

  // Sets the in-memory clean-close flag and immediately fires the Hive write
  // (unawaited). Writing eagerly — before navigation — is safer than deferring
  // to onClose: the process is still foreground and the isCleanClose flag
  // already blocks any further snapshot writes, so there is no race.
  // No-op on non-Android: composerAutoSaveProvider is only initialised on
  // Android, so reading it on other platforms would create an orphaned family
  // entry that is never invalidated (memory leak).
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

  // Runs every _periodicSnapshotInterval while the composer is open.
  //
  // Two responsibilities:
  //   1. Keep lastKnownHtmlContent fresh (fallback for _saveSnapshotToCache).
  //   2. Save the draft to the server, but ONLY when the app is visibly
  //      foreground and the full composer state has actually changed.
  //
  // Deliberately NOT triggered from the inactive path: a background JMAP call
  // may need to refresh the token, and the system can terminate the Hive write
  // mid-flight, leaving the account cache in a corrupt state (ADR-0086).
  Future<void> _periodicSaveTask() async {
    final content = await _fetchEditorContent();
    if (content != null) _autoSaveNotifier()?.updateLastKnownContent(content);

    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) return;

    final notifier = _autoSaveNotifier();
    if (notifier == null || notifier.isCleanClose) return;

    final int currentHash;
    try {
      currentHash = await hashComposerStateForAutoSave().timeout(_getContentTimeout);
    } on TimeoutException {
      log('HandleMobileAutoSaveExtension::_periodicSaveTask: hash timeout, skip');
      return;
    }
    if (currentHash == lastAutoSavedToServerHash) return;

    final effectiveContent = content ?? notifier.lastKnownHtmlContent;
    final createEmailRequest = await buildCreateEmailRequestForAutoSave(
      htmlContent: effectiveContent,
    );
    if (createEmailRequest == null) return;

    // Set optimistically: if the save fails, skip retry until content changes
    // (the local Hive snapshot already holds the data as a safety net).
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
    try {
      final payload = await _resolveRestorePayload();
      if (payload == null) return;
      // Re-check after the async gap: the user may have closed the composer
      // while _resolveRestorePayload was awaiting. isClosed covers the case
      // where onClose() already ran (notifier invalidated → fresh isCleanClose=false);
      // isCleanClose covers the window between markCleanClose() and onClose().
      if (isClosed || _autoSaveNotifier()?.isCleanClose == true) return;
      log('HandleMobileAutoSaveExtension::restoreIfEditorBlank: restoring from cache');
      await payload.api.setText(payload.html);
      // Keep the fallback snapshot in sync: if the editor dies before the next
      // periodic tick, _saveSnapshotToCache will use this restored content.
      if (payload.html.isNotEmpty) _autoSaveNotifier()?.updateLastKnownContent(payload.html);
      // Delete the stale snapshot now that its content is live in the editor.
      // The periodic timer will write a fresh snapshot on the next 30 s tick.
      unawaited(clearComposerMobileSnapshot());
    } catch (e) {
      log('HandleMobileAutoSaveExtension::restoreIfEditorBlank: error=$e');
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

  // Picks the best available content and syncs it to the notifier.
  // Fresh content from the editor takes priority; falls back to the last
  // periodic snapshot (ADR-0086 Layer 1 fallback requirement).
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
      // Re-check: markCleanClose() may have fired during the async gaps above.
      // Without this guard, _executeCacheSave() would write isCleanClose=false
      // to Hive, racing against _persistCleanCloseToCache() which writes true.
      if (notifier.isCleanClose) return;
      await _executeCacheSave(createEmailRequest, notifier);
      // Draft-to-server save is intentionally excluded here: this path fires
      // on AppLifecycleState.inactive (app going to background). A background
      // JMAP call can trigger a token refresh whose Hive write the system may
      // terminate before completion, corrupting the account cache.
      // Server saves are handled exclusively by _periodicSaveTask(), which
      // guards on AppLifecycleState.resumed.
    } catch (e) {
      log('HandleMobileAutoSaveExtension::_saveSnapshotToCache: error=$e');
    }
  }

  void _onDraftSaveState(Either<Failure, Success> state) {
    state.fold(
      (failure) {
        // Privacy: only the type is sent — no content, subject, or recipients.
        logError('HandleMobileAutoSaveExtension::_onDraftSaveState: failure=${failure.runtimeType}');
      },
      (success) {
        // Do NOT clear the Hive cache here: the periodic auto-save may have
        // written a newer snapshot while this JMAP call was in flight (race
        // condition on slow networks). Cleanup is handled by markCleanClose
        // (intentional close) and the 24 h TTL on ComposerPersistentCache.
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
      // Privacy: only the type is captured.
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
