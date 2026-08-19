import 'package:core/core.dart';
import 'package:core/utils/html/file_link_card_html_builder.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/drive_document_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/drive_attachment_transfer_runner.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';

/// Transfers [docs] as real attachments, reporting the batch outcome.
typedef TransferDriveDocumentsCallback = Future<DriveTransferOutcome> Function(List<DriveDocument> docs);

/// Inserts [html] at the caret; false when no editor is bound to insert into.
typedef InsertHtmlCallback = Future<bool> Function(String html);

class DriveAttachmentHandler {
  DriveAttachmentHandler();

  static const _fallbackOpenInDriveLabel = 'Open in drive';

  /// Whether non-https sharing/thumbnail links should be rejected.
  bool get requireHttps => BuildUtils.isReleaseMode;

  Future<void> handleDrivePickResult(
    List<DriveDocument> result, {
    required InsertHtmlCallback insertHtml,
    required TransferDriveDocumentsCallback transferDriveDocuments,
    AppLocalizations? appLocalizations,
  }) async {
    if (result.isEmpty) {
      _showFailureToast(appLocalizations?.driveNoValidAttachment);
      return;
    }
    final (linkDocs, downloadableDocs, droppedCount) =
        _splitByAttachability(result);

    // A mixed pick inserts its links and transfers its downloadable docs.
    var linkInserted = false;
    if (linkDocs.isNotEmpty) {
      linkInserted = await insertDriveLinkHtml(
        linkDocs,
        insertHtml: insertHtml,
        appLocalizations: appLocalizations,
      );
    }

    if (downloadableDocs.isNotEmpty) {
      await _transferDownloadableDocs(
        downloadableDocs,
        linkInserted: linkInserted,
        transferDriveDocuments: transferDriveDocuments,
        appLocalizations: appLocalizations,
      );
    } else if (linkInserted) {
      _showSuccessToast(appLocalizations?.driveAttachmentAddedSuccessfully);
    } else if (linkDocs.isEmpty) {
      _showFailureToast(appLocalizations?.driveNoValidAttachment);
    } else {
      // Docs were linkable but the editor was unbound — nothing reached the body.
      _showFailureToast(appLocalizations?.driveAttachmentTransferFailed);
    }

    // Dropped docs would otherwise vanish silently from a pick whose siblings worked.
    if (droppedCount > 0 && (linkDocs.isNotEmpty || downloadableDocs.isNotEmpty)) {
      _showFailureToast(appLocalizations?.driveNoValidAttachment);
    }
  }

  /// Splits [result] into (linkable docs, downloadable docs, dropped count).
  (List<DriveDocument>, List<DriveDocument>, int) _splitByAttachability(
    List<DriveDocument> result,
  ) {
    final linkDocs = <DriveDocument>[];
    final downloadableDocs = <DriveDocument>[];
    var droppedCount = 0;
    for (final doc in result) {
      if (doc.isAttachableAsLink(requireHttps: requireHttps)) {
        linkDocs.add(doc);
      } else if (doc.isAttachableAsDownload()) {
        downloadableDocs.add(doc);
      } else {
        droppedCount++;
      }
    }
    return (linkDocs, downloadableDocs, droppedCount);
  }

  /// Transfers [downloadableDocs], toasting the batch outcome. A partial
  /// failure stays silent here: each failed chip already toasts its own error.
  Future<void> _transferDownloadableDocs(
    List<DriveDocument> downloadableDocs, {
    required bool linkInserted,
    required TransferDriveDocumentsCallback transferDriveDocuments,
    AppLocalizations? appLocalizations,
  }) async {
    final outcome = await transferDriveDocuments(downloadableDocs);
    if (!outcome.started) {
      _showFailureToast(appLocalizations?.driveAttachmentTransferFailed);
      return;
    }
    if (outcome.failed == 0 && (linkInserted || outcome.succeeded > 0)) {
      _showSuccessToast(appLocalizations?.driveAttachmentAddedSuccessfully);
    }
  }

  /// Toasts [message], or logs if no [ToastManager] is bound.
  void _showFailureToast(String? message) {
    final toastManager = getBinding<ToastManager>();
    if (toastManager == null) {
      logWarning(
        'DriveAttachmentHandler::_showFailureToast: no ToastManager bound, '
        'failure not shown to the user',
      );
      return;
    }
    toastManager.showMessageFailure(
      DrivePickFailure(Exception(), message: message),
    );
  }

  /// Toasts [message], or logs if no [ToastManager] is bound.
  void _showSuccessToast(String? message) {
    final toastManager = getBinding<ToastManager>();
    if (toastManager == null) {
      logWarning(
        'DriveAttachmentHandler::_showSuccessToast: no ToastManager bound, '
        'success not shown to the user',
      );
      return;
    }
    toastManager.showMessageSuccess(DrivePickSuccess(message: message));
  }

  Future<bool> insertDriveLinkHtml(
    List<DriveDocument> docs, {
    required InsertHtmlCallback insertHtml,
    AppLocalizations? appLocalizations,
  }) {
    return insertHtml(
      buildDriveLinksHtml(docs, appLocalizations: appLocalizations),
    );
  }

  String buildDriveLinksHtml(
    List<DriveDocument> docs, {
    AppLocalizations? appLocalizations,
  }) {
    final cards = docs
        .map(
          (doc) => _driveFileCard(
            doc,
            appLocalizations: appLocalizations,
          ),
        )
        .nonNulls
        .toList();
    return FileLinkCardHtmlBuilder.wrapFileCardsHtml(cards);
  }

  String? _driveFileCard(
    DriveDocument doc, {
    AppLocalizations? appLocalizations,
  }) {
    if (!doc.isAttachableAsLink(requireHttps: requireHttps)) return null;
    final link = doc.sharingLink!;

    final openInDriveLabel =
        appLocalizations?.openInDrive ?? _fallbackOpenInDriveLabel;
    final trustedThumbnailUrl = _trustedThumbnailUrl(doc);

    return FileLinkCardHtmlBuilder.buildFileLinkCard(
      FileLinkCardContent(
        href: link.toString(),
        title: doc.name,
        actionLabel: openInDriveLabel,
        iconZoneHtml: FileLinkCardHtmlBuilder.buildFileCardIconZone(
          imageUrl: trustedThumbnailUrl?.toString(),
        ),
      ),
    );
  }

  Uri? _trustedThumbnailUrl(DriveDocument doc) {
    final thumbnailUrl = doc.thumbnail?.link;
    if (thumbnailUrl == null) return null;
    if (!thumbnailUrl.isScheme('https') && requireHttps) {
      return null;
    }

    return thumbnailUrl;
  }
}
