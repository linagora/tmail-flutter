import 'package:core/utils/html/file_link_card_html_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:workplace/domain/entity/drive_document.dart';

class DriveAttachmentHandler {
  DriveAttachmentHandler({required this.requireHttps});

  static const _fallbackOpenInDriveLabel = 'Open in drive';

  /// Whether non-https sharing/thumbnail links should be rejected.
  /// Injected by the binding so it reflects the app's build mode
  /// without this class depending on `BuildUtils` directly.
  final bool requireHttps;

  void handleDrivePickResult(
    List<DriveDocument> result, {
    required void Function(String html) insertHtml,
    AppLocalizations? appLocalizations,
  }) {
    final linkDocs = result.where((doc) => doc.sharingLink != null).toList();
    insertDriveLinkHtml(
      linkDocs,
      insertHtml: insertHtml,
      appLocalizations: appLocalizations,
    );
  }

  void insertDriveLinkHtml(
    List<DriveDocument> docs, {
    required void Function(String html) insertHtml,
    AppLocalizations? appLocalizations,
  }) {
    insertHtml(
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
        .join();
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
      href: link.toString(),
      title: doc.name,
      actionLabel: openInDriveLabel,
      iconZoneHtml: FileLinkCardHtmlBuilder.buildFileCardIconZone(
        imageUrl: trustedThumbnailUrl?.toString(),
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
