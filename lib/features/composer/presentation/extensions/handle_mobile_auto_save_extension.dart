import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_auto_save_notifier.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_cache_providers.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
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

  // Only saves to server when resumed: inactive path risks corrupting the
  // account cache if a background token refresh is killed mid-write.
  Future<void> _periodicSaveTask() async {
    final content = await _fetchEditorContent();
    if (content != null) _autoSaveNotifier()?.updateLastKnownContent(content);

    final notifier = _guardedNotifierForSave();
    if (notifier == null) return;

    await _attemptServerSave(content, notifier);
  }

  // Returns null when conditions disqualify a server save this tick.
  ComposerAutoSaveNotifier? _guardedNotifierForSave() {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) return null;
    // Block saves while a restore+blobId refresh is in flight.
    if (isRestoringFromCache) return null;
    final notifier = _autoSaveNotifier();
    if (notifier == null || notifier.isCleanClose) return null;
    return notifier;
  }

  Future<void> _attemptServerSave(
    String? content,
    ComposerAutoSaveNotifier notifier,
  ) async {
    // Don't consume the hash while a save is in-flight: the next tick must
    // retry with the updated hash once the in-flight save finishes.
    if (notifier.isSavingToDraftInProgress) return;

    final int? currentHash = await _computeHashOrNull(content);
    if (currentHash == null || currentHash == lastAutoSavedToServerHash) return;

    final effectiveContent = content ?? notifier.lastKnownHtmlContent;
    final createEmailRequest = await buildCreateEmailRequestForAutoSave(
      htmlContent: effectiveContent,
    );
    if (createEmailRequest == null) {
      log('HandleMobileAutoSaveExtension::_attemptServerSave: request is null, skip');
      return;
    }

    // Optimistic: on failure, retry is deferred until content changes.
    lastAutoSavedToServerHash = currentHash;
    unawaited(_saveToDraftSilently(createEmailRequest));
  }

  Future<int?> _computeHashOrNull(String? content) async {
    try {
      return await hashComposerStateForAutoSave(htmlContent: content).timeout(_getContentTimeout);
    } on TimeoutException {
      log('HandleMobileAutoSaveExtension::_computeHashOrNull: hash timeout, skip');
      return null;
    }
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
    final cachedDraftId = payload.draftEmailId;
    if (cachedDraftId != null && emailIdEditing != cachedDraftId) {
      emailIdEditing = cachedDraftId;
      log('HandleMobileAutoSaveExtension::_applyRestoredPayload: synced emailIdEditing=${cachedDraftId.id.value}');
      // Old draft was destroyed by last auto-save; refresh blobIds before next save.
      // Awaited so that isRestoringFromCache=true blocks _periodicSaveTask
      // until fresh blobIds are in place.
      await _refreshInlineAttachmentsFromDraft(cachedDraftId);
    }
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

  // updateEmailDrafts destroys the old draft, invalidating its server-side
  // part-blobIds. Refresh so the next auto-save uses the new draft's valid blobs.
  Future<void> _refreshInlineAttachmentsFromDraft(EmailId draftEmailId) async {
    if (uploadController.mapInlineAttachments.isEmpty) return;

    // Snapshot before the async gap: images inserted after this point must
    // survive the refresh and are not included in staleTaskIds.
    final staleTaskIds = uploadController.mapInlineAttachments.values
        .where((a) => a.blobId != null)
        .map((a) => UploadTaskId(a.blobId!.value))
        .toSet();

    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;
    final baseDownloadUrl = mailboxDashBoardController.baseDownloadUrl;
    if (session == null || accountId == null || baseDownloadUrl.isEmpty) return;

    try {
      final resultState = await getEmailContentInteractor.execute(
        session,
        accountId,
        draftEmailId,
        baseDownloadUrl,
        TransformConfiguration.forEditDraftsEmail(),
        additionalProperties: Properties({EmailProperty.attachments}),
      ).last;

      resultState.fold(
        (failure) => logError(
          'HandleMobileAutoSaveExtension::_refreshInlineAttachmentsFromDraft: '
          'failed=${failure.runtimeType}',
          exception: failure is FeatureFailure ? failure.exception : null,
        ),
        (success) {
          final fresh = switch (success) {
            GetEmailContentSuccess s => s.inlineImages,
            GetEmailContentFromCacheSuccess s => s.inlineImages,
            _ => null,
          };
          if (fresh?.isNotEmpty == true) {
            uploadController.refreshInlineAttachments(staleTaskIds, fresh!);
            log(
              'HandleMobileAutoSaveExtension::_refreshInlineAttachmentsFromDraft: '
              'refreshed ${fresh.length} inline blobIds',
            );
          }
        },
      );
    } catch (e) {
      logError(
        'HandleMobileAutoSaveExtension::_refreshInlineAttachmentsFromDraft: error=${e.runtimeType}',
      );
    }
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
      // Server save skipped on inactive: see _periodicSaveTask().
    } catch (e) {
      logError(
        'HandleMobileAutoSaveExtension::_saveSnapshotToCache: error=${e.runtimeType}',
      );
    }
  }

  // Returns the new draft ID when the draft was updated (old one destroyed),
  // so the caller can refresh stale blobIds while isSavingToDraftInProgress is still true.
  EmailId? _onDraftSaveState(Either<Failure, Success> state) {
    return state.fold(
      (failure) {
        // Privacy: no user content. exception carries the network/JMAP cause.
        logError(
          'HandleMobileAutoSaveExtension::_onDraftSaveState: failure=${failure.runtimeType}',
          exception: failure is FeatureFailure ? failure.exception : null,
          extras: {'isFirstSave': emailIdEditing == null},
        );
        return null;
      },
      (success) {
        // Hive snapshot not cleared: a newer one may have been written in-flight.
        if (success is SaveEmailAsDraftsSuccess) {
          emailIdEditing = success.emailId;
          log('HandleMobileAutoSaveExtension::_onDraftSaveState: saved to server draft');
          return null;
        } else if (success is UpdateEmailDraftsSuccess) {
          emailIdEditing = success.emailId;
          log('HandleMobileAutoSaveExtension::_onDraftSaveState: updated server draft');
          // Signal caller to refresh blobIds — old draft was destroyed.
          return success.emailId;
        }
        return null;
      },
    );
  }

  Future<void> _saveToDraftSilently(CreateEmailRequest createEmailRequest) async {
    final notifier = _autoSaveNotifier();
    if (notifier == null || notifier.isSavingToDraftInProgress) return;

    notifier.beginDraftSave();
    EmailId? updatedDraftId;
    try {
      await for (final state in createNewAndSaveEmailToDraftsInteractor.execute(
        createEmailRequest: createEmailRequest,
      )) {
        updatedDraftId = _onDraftSaveState(state);
      }
      // Awaited inside the try so isSavingToDraftInProgress stays true until
      // fresh blobIds are in place — the next periodic tick cannot proceed with
      // stale D1 blobIds while this refresh is in flight.
      if (updatedDraftId != null) {
        await _refreshInlineAttachmentsFromDraft(updatedDraftId);
      }
    } catch (e, st) {
      // Privacy: type only — exception message may embed network details.
      logError(
        'HandleMobileAutoSaveExtension::_saveToDraftSilently: error=${e.runtimeType}',
        exception: e,
        stackTrace: st,
      );
    } finally {
      if (notifier.mounted) notifier.endDraftSave();
    }
  }

  // Public entry point for any save path that calls updateEmailDrafts outside
  // of _saveToDraftSilently (e.g. manual "Save as draft" button).
  Future<void> onManualDraftUpdateRefreshBlobIds(EmailId newDraftId) {
    if (!PlatformInfo.isAndroid) return Future.value();
    return _refreshInlineAttachmentsFromDraft(newDraftId);
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
