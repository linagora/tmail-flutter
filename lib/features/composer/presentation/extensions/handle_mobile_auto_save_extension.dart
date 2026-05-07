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
      await _executeCacheSave(createEmailRequest, notifier);
      unawaited(_saveToDraftSilently(createEmailRequest));
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
