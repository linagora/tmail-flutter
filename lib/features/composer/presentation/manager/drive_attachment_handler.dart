import 'dart:convert';

import 'package:core/utils/build_utils.dart';
import 'package:workplace/domain/entity/drive_document.dart';

class DriveAttachmentHandler {
  const DriveAttachmentHandler();

  void handleDrivePickResult(
    List<DriveDocument> result, {
    required void Function(String html) insertHtml,
  }) {
    final linkDocs = result.where((doc) => doc.sharingLink != null).toList();
    insertDriveLinkHtml(linkDocs, insertHtml: insertHtml);
  }

  void insertDriveLinkHtml(
    List<DriveDocument> docs, {
    required void Function(String html) insertHtml,
  }) {
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
}
