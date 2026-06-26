import 'dart:async';
import 'dart:convert';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
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
    final partition = _partitionDriveDocs(result);
    insertDriveLinkHtml(partition.linkDocs);
    unawaited(downloadAndUploadDriveFile(partition.attachmentDocs));
  }

  static ({List<DriveDocument> linkDocs, List<DriveDocument> attachmentDocs})
  _partitionDriveDocs(List<DriveDocument> docs) {
    final linkDocs = <DriveDocument>[];
    final attachmentDocs = <DriveDocument>[];
    for (final doc in docs) {
      if (doc.sharingLink != null) {
        linkDocs.add(doc);
      } else if (doc.downloadLink != null) {
        attachmentDocs.add(doc);
      }
    }
    return (linkDocs: linkDocs, attachmentDocs: attachmentDocs);
  }

  void insertDriveLinkHtml(List<DriveDocument> docs) {
    insertHtml(buildDriveLinksHtml(docs));
  }

  static String buildDriveLinksHtml(
    List<DriveDocument> docs, {
    bool requireHttps = BuildUtils.isReleaseMode,
  }) {
    return docs
        .map((doc) => _driveLinkAnchor(doc, requireHttps: requireHttps))
        .nonNulls
        .join('<br>');
  }

  static String? _driveLinkAnchor(
    DriveDocument doc, {
    required bool requireHttps,
  }) {
    final link = doc.sharingLink;
    if (link == null) return null;
    if (requireHttps && !link.isScheme('https')) return null;

    final href = const HtmlEscape(
      HtmlEscapeMode.attribute,
    ).convert(link.toString());
    final label = const HtmlEscape().convert(doc.name);
    return '<a href="$href">$label</a>';
  }

  Future<void> downloadAndUploadDriveFile(List<DriveDocument> docs) async {
    final downloadableDocs = docs
        .where((doc) => doc.downloadLink != null)
        .toList();
    if (downloadableDocs.isEmpty) return;
    try {
      uploadController.validateTotalSizeAttachmentsBeforeUpload(
        totalSizePreparedFiles: downloadableDocs.fold(
          0,
          (prev, doc) => prev + doc.size,
        ),
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
