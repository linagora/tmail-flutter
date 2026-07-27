import 'package:core/core.dart';
import 'package:core/utils/html/file_link_card_html_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';

class DriveAttachmentHandler {
  DriveAttachmentHandler();

  static const _fallbackOpenInDriveLabel = 'Open in drive';

  /// Whether non-https sharing/thumbnail links should be rejected.
  bool get requireHttps => BuildUtils.isReleaseMode;

  Future<void> handleDrivePickResult(
    List<DriveDocument> result, {
    required Future<void> Function(String html) insertHtml,
    AppLocalizations? appLocalizations,
  }) async {
    if (result.isEmpty) {
      getBinding<ToastManager>()?.showMessageFailure(
        DrivePickFailure(
          Exception(),
          message: appLocalizations?.driveNoValidAttachment,
        ),
      );
      return;
    }
    final linkDocs = result.where((doc) {
      final link = doc.sharingLink;
      return link != null && (!requireHttps || link.isScheme('https'));
    }).toList();
    // TODO: Update logic here after implement 103. Attach Drive File as Attachment
    if (linkDocs.isEmpty) {
      getBinding<ToastManager>()?.showMessageFailure(DrivePickFailure(
        Exception(),
        message: appLocalizations?.driveAttachmentInDevelopment,
      ));
      return;
    }
    await insertDriveLinkHtml(
      linkDocs,
      insertHtml: insertHtml,
      appLocalizations: appLocalizations,
    );
  }

  Future<void> insertDriveLinkHtml(
    List<DriveDocument> docs, {
    required Future<void> Function(String html) insertHtml,
    AppLocalizations? appLocalizations,
  }) async {
    await insertHtml(
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
    final link = doc.sharingLink;
    if (link == null) return null;
    if (requireHttps && !link.isScheme('https')) return null;

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
