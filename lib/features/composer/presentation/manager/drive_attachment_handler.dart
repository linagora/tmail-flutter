import 'dart:convert';

import 'package:core/utils/build_utils.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:workplace/domain/entity/drive_document.dart';

class DriveAttachmentHandler {
  DriveAttachmentHandler();

  static const _fallbackOpenInDriveLabel = 'Open in drive';

  static const _hrefEscape = HtmlEscape(HtmlEscapeMode.attribute);
  static const _textEscape = HtmlEscape();

  Future<void> handleDrivePickResult(
    List<DriveDocument> result, {
    required void Function(String html) insertHtml,
    AppLocalizations? appLocalizations,
  }) async {
    final linkDocs = result.where((doc) => doc.sharingLink != null).toList();
    await insertDriveLinkHtml(
      linkDocs,
      insertHtml: insertHtml,
      appLocalizations: appLocalizations,
    );
  }

  Future<void> insertDriveLinkHtml(
    List<DriveDocument> docs, {
    required void Function(String html) insertHtml,
    AppLocalizations? appLocalizations,
  }) async {
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
    return HtmlUtils.wrapFileCardsHtml(cards);
  }

  String? _driveFileCard(
    DriveDocument doc, {
    required bool requireHttps,
    AppLocalizations? appLocalizations,
  }) {
    final link = doc.sharingLink;
    if (link == null) return null;
    if (requireHttps && !link.isScheme('https')) return null;

    final href = _hrefEscape.convert(link.toString());
    final name = _textEscape.convert(doc.name);
    final openInDriveLabel = _textEscape.convert(
      appLocalizations?.openInDrive ?? _fallbackOpenInDriveLabel,
    );
    final thumbnailUrl = doc.thumbnail?.link;

    return HtmlUtils.buildFileLinkCard(
      href: href,
      title: name,
      actionLabel: openInDriveLabel,
      iconZoneHtml: HtmlUtils.buildFileCardIconZone(
        imageUrl: thumbnailUrl != null ? _hrefEscape.convert(thumbnailUrl.toString()) : '',
      ),
    );
  }
}
