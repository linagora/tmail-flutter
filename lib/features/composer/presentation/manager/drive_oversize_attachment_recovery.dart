import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/file_link_card_html_builder.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/drive_attachment_handler.dart';
import 'package:tmail_ui_user/features/upload/data/network/upload_body.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request.dart';
import 'package:tmail_ui_user/features/upload/presentation/dialog/drive_oversize_upload_dialog_presenter.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/drive_oversize_transfer_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/providers/drive_oversize_transfer_notifier.dart';
import 'package:tmail_ui_user/features/upload/presentation/validator/attachment_upload_recovery.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_uri_value_notifier_provider.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_oversize_uploader_provider.dart'
    show DriveOversizeUploader, driveOversizeUploaderProvider;
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:workplace/domain/entity/workplace_request_context.dart';
import 'package:workplace/domain/entity/workplace_upload_file_spec.dart';
import 'package:workplace/domain/usecase/drive_oversize_upload_call.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';

typedef _LinkedFile = ({String name, Uri link});

class DriveOversizeAttachmentRecovery implements AttachmentUploadRecovery {
  final BuildContext _context;
  final InsertHtmlCallback _insertHtml;

  DriveOversizeAttachmentRecovery({
    required BuildContext context,
    required InsertHtmlCallback insertHtml,
  })  : _context = context,
        _insertHtml = insertHtml;

  @override
  Future<bool> recover(
    AttachmentUploadFailure failure,
    AttachmentUploadRequest request,
  ) async {
    final container = ProviderScope.containerOf(_context, listen: false);
    // Null means fqdn, ecosystem flag or user preference says no Drive: decline,
    // and the gate shows today's size dialog.
    final platformUrl = container.read(driveAttachmentUriValueProvider).value;
    if (platformUrl == null) return false;

    final files = request.regularFiles;
    if (files.isEmpty) return false;

    final items = files
        .map((file) => DriveOversizeTransferState(
              taskId: UploadTaskId(const Uuid().v4()),
              fileName: file.fileName,
              fileSize: file.fileSize,
              cancelToken: CancelToken(),
            ))
        .toList();

    container.read(driveOversizeTransferProvider.notifier).start(items);
    DriveOversizeUploadDialogPresenter.show(container);

    // Deliberately not awaited: the contract completes at takeover, not at
    // upload completion, or every validateFiles caller waits for the transfer.
    unawaited(_transfer(container, platformUrl, files, items));
    return true;
  }

  Future<void> _transfer(
    ProviderContainer container,
    Uri platformUrl,
    List<FileInfo> files,
    List<DriveOversizeTransferState> items,
  ) async {
    final notifier = container.read(driveOversizeTransferProvider.notifier);
    final linked = <_LinkedFile>[];
    final appLocalizations =
        currentContext == null ? null : AppLocalizations.of(currentContext!);
    var hasFailedUpload = false;
    var inserted = true;

    try {
      await _runUploads(container, notifier, platformUrl, files, items, linked);
      // Any row still failed once uploads settle (cancelled rows don't count).
      hasFailedUpload = container
          .read(driveOversizeTransferProvider)
          .any((item) => item.status == DriveOversizeTransferStatus.failed);
      // Links go in before any toast: a new platform view can drop a pending web editor insert.
      if (linked.isNotEmpty) {
        inserted = await _insertLinks(linked, appLocalizations);
      }
    } finally {
      // The dialog closes on every path, so the composer is never left blocked.
      DriveOversizeUploadDialogPresenter.close();
      notifier.clear();
    }

    if (hasFailedUpload || !inserted) {
      _showFailureToast(appLocalizations);
    }
  }

  Future<void> _runUploads(
    ProviderContainer container,
    DriveOversizeTransfer notifier,
    Uri platformUrl,
    List<FileInfo> files,
    List<DriveOversizeTransferState> items,
    List<_LinkedFile> linked,
  ) async {
    final uploader = container.read(driveOversizeUploaderProvider);
    try {
      await uploader.runner.run(
        platformUrl,
        DriveOversizeUploadCall((accessMode) => _uploadAll(
              context: WorkplaceRequestContext(platformUrl: platformUrl, accessMode: accessMode),
              uploader: uploader,
              notifier: notifier,
              files: files,
              items: items,
              linked: linked,
            )),
      );
    } catch (error) {
      // Failed outside a per-file catch (token exchange, bridge): fail only
      // unsettled rows, so an already-linked row keeps its label.
      logError('DriveOversizeAttachmentRecovery::_runUploads: $error');
      for (final item in container.read(driveOversizeTransferProvider)) {
        if (!item.status.settled) notifier.markFailed(item.taskId);
      }
    }
  }

  Future<List<Uri>> _uploadAll({
    required WorkplaceRequestContext context,
    required DriveOversizeUploader uploader,
    required DriveOversizeTransfer notifier,
    required List<FileInfo> files,
    required List<DriveOversizeTransferState> items,
    required List<_LinkedFile> linked,
  }) async {
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final file = files[index];
      // A row the user already cancelled is never started.
      if (item.cancelToken.isCancelled) continue;
      await _uploadOne(context, uploader, notifier, file, item, linked);
    }
    return linked.map((entry) => entry.link).toList();
  }

  Future<void> _uploadOne(
    WorkplaceRequestContext context,
    DriveOversizeUploader uploader,
    DriveOversizeTransfer notifier,
    FileInfo file,
    DriveOversizeTransferState item,
    List<_LinkedFile> linked,
  ) async {
    try {
      notifier.markUploading(item.taskId);
      final body = UploadBody.of(file);
      final link = await uploader.interactor.execute(
        context: context,
        spec: WorkplaceUploadFileSpec(
          fileName: file.fileName,
          mimeType: file.mimeType,
          fileSize: file.fileSize,
          source: body,
        ),
        onProgress: (count, total) => notifier.reportProgress(item.taskId, count, total),
        cancelSignal: item.cancelToken.whenCancel,
      );
      linked.add((name: file.fileName, link: link));
      notifier.markLinked(item.taskId);
    } on DioException catch (exception) {
      // A cancel is the user's own doing — the row already says so.
      if (exception.type == DioExceptionType.cancel) return;
      logError('DriveOversizeAttachmentRecovery::_uploadOne: $exception');
      notifier.markFailed(item.taskId);
    } catch (e) {
      logError('DriveOversizeAttachmentRecovery::_uploadOne: $e');
      notifier.markFailed(item.taskId);
    }
  }

  Future<bool> _insertLinks(
    List<_LinkedFile> linked,
    AppLocalizations? appLocalizations,
  ) async {
    final cards = linked
        .map((entry) => FileLinkCardHtmlBuilder.buildFileLinkCard(FileLinkCardContent(
              href: entry.link.toString(),
              title: entry.name,
              actionLabel: appLocalizations?.openInDrive ?? 'Open in drive',
              iconZoneHtml: FileLinkCardHtmlBuilder.buildFileCardIconZone(),
            )))
        .toList();

    try {
      final inserted =
          await _insertHtml(FileLinkCardHtmlBuilder.wrapFileCardsHtml(cards));
      // An editor that refused the HTML would otherwise lose the links silently.
      if (!inserted) {
        logError('DriveOversizeAttachmentRecovery::_insertLinks: editor refused');
      }
      return inserted;
    } catch (error) {
      logError('DriveOversizeAttachmentRecovery::_insertLinks: $error');
      return false;
    }
  }

  void _showFailureToast(AppLocalizations? appLocalizations) {
    final context = currentContext;
    if (context == null || appLocalizations == null) return;
    getBinding<ToastManager>()?.showMessageFailure(
      DrivePickFailure(
        Exception(),
        message: appLocalizations.driveOversizeUploadFailed,
      ),
    );
  }
}
