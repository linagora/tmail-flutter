import 'dart:convert';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/state/download_drive_file_state.dart';
import 'package:workplace/domain/usecases/download_drive_file_interactor.dart';

class DriveAttachmentHandler {
  final UploadController uploadController;
  final DownloadDriveFileInteractor downloadDriveFileInteractor;
  final void Function(String html) insertHtml;
  final void Function({required List<FileInfo> pickedFiles}) uploadFiles;
  final void Function(Object error)? onError;

  const DriveAttachmentHandler({
    required this.uploadController,
    required this.downloadDriveFileInteractor,
    required this.insertHtml,
    required this.uploadFiles,
    this.onError,
  });

  void handleDrivePickResult(List<DriveDocument> result) {
    final linkDocs = <DriveDocument>[];
    final attachmentDocs = <DriveDocument>[];
    for (final doc in result) {
      if (doc.sharingLink != null) {
        linkDocs.add(doc);
      } else if (doc.downloadLink != null) {
        attachmentDocs.add(doc);
      }
    }
    insertDriveLinkHtml(linkDocs);
    downloadAndUploadDriveFile(attachmentDocs);
  }

  void insertDriveLinkHtml(List<DriveDocument> docs) {
    final linkHtml = docs
        .map((doc) {
          final link = doc.sharingLink;
          if (link == null) return null;
          if (!link.isScheme('https') && kReleaseMode) return null;
          final href = const HtmlEscape(HtmlEscapeMode.attribute).convert(link.toString());
          final label = const HtmlEscape().convert(doc.name);
          return '<a href="$href">$label</a>';
        })
        .nonNulls
        .join('<br>');
    insertHtml(linkHtml);
  }

  Future<void> downloadAndUploadDriveFile(List<DriveDocument> docs) async {
    final downloadableDocs = docs.where((doc) => doc.downloadLink != null).toList();
    if (downloadableDocs.isEmpty) return;
    try {
      uploadController.validateTotalSizeAttachmentsBeforeUpload(
        totalSizePreparedFiles: downloadableDocs.fold(0, (prev, doc) => prev + doc.size),
        onValidationSuccess: () => _processDownloadableDocs(downloadableDocs),
      );
    } catch (e) {
      logWarning('DriveAttachmentHandler::downloadAndUploadDriveFile: $e');
      onError?.call(e);
    }
  }

  Future<void> _processDownloadableDocs(List<DriveDocument> docs) async {
    final downloadedFiles = <FileInfo>[];
    for (final doc in docs) {
      await for (final state in downloadDriveFileInteractor.execute(doc)) {
        state.fold(
          (failure) => logWarning(
            'DriveAttachmentHandler::downloadAndUploadDriveFile: Fail to process ${doc.name}: $failure',
          ),
          (success) {
            if (success is DownloadDriveFileSuccess) {
              downloadedFiles.add(success.fileInfo);
            }
          },
        );
      }
    }
    if (downloadedFiles.isNotEmpty) {
      uploadFiles(pickedFiles: downloadedFiles);
    }
  }
}
