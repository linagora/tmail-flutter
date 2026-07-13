import 'package:core/utils/build_utils.dart';
import 'package:core/utils/html/file_link_card_html_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:workplace/domain/entity/drive_document.dart';

class DriveAttachmentHandler {
  DriveAttachmentHandler();

  static const _fallbackOpenInDriveLabel = 'Open in drive';

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
    bool requireHttps = BuildUtils.isReleaseMode,
  }) {
    final cards = docs
        .map(
          (doc) => _driveFileCard(
            doc,
            requireHttps: requireHttps,
            appLocalizations: appLocalizations,
          ),
        )
        .nonNulls
        .join();
    return FileLinkCardHtmlBuilder.wrapFileCardsHtml(cards);
  }

  String? _driveFileCard(
    DriveDocument doc, {
    required bool requireHttps,
    AppLocalizations? appLocalizations,
  }) {
    final link = doc.sharingLink;
    if (link == null) return null;
    if (requireHttps && !link.isScheme('https')) return null;

    final openInDriveLabel =
        appLocalizations?.openInDrive ?? _fallbackOpenInDriveLabel;
    final trustedThumbnailUrl = _trustedThumbnailUrl(doc, sharingLink: link);

    return FileLinkCardHtmlBuilder.buildFileLinkCard(
      href: link.toString(),
      title: doc.name,
      actionLabel: openInDriveLabel,
      iconZoneHtml: FileLinkCardHtmlBuilder.buildFileCardIconZone(
        imageUrl: trustedThumbnailUrl?.toString(),
      ),
    );
  }

  /// Only trust a thumbnail URL that is https and hosted on the same domain
  /// (or a subdomain, e.g. a CDN) as the already-validated sharing link, so a
  /// compromised/forged thumbnail URL can't be used to load an arbitrary
  /// image from an untrusted host.
  Uri? _trustedThumbnailUrl(DriveDocument doc, {required Uri sharingLink}) {
    final thumbnailUrl = doc.thumbnail?.link;
    if (thumbnailUrl == null) return null;
    if (!thumbnailUrl.isScheme('https')) return null;

    final trustedDomain = _registrableDomain(sharingLink.host);
    final isSameOrSubdomain = thumbnailUrl.host == trustedDomain ||
        thumbnailUrl.host.endsWith('.$trustedDomain');
    if (!isSameOrSubdomain) return null;

    return thumbnailUrl;
  }

  String _registrableDomain(String host) {
    final labels = host.split('.');
    if (labels.length <= 2) return host;
    return labels.sublist(labels.length - 2).join('.');
  }
}
