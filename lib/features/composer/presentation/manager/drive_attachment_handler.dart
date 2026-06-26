import 'dart:convert';

import 'package:core/utils/build_utils.dart';
import 'package:workplace/domain/entity/drive_document.dart';

class DriveAttachmentHandler {
  final void Function(String html) insertHtml;

  const DriveAttachmentHandler({required this.insertHtml});

  void handleDrivePickResult(List<DriveDocument> result) {
    final linkDocs = result.where((doc) => doc.sharingLink != null).toList();
    insertDriveLinkHtml(linkDocs);
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

    final href = const HtmlEscape(HtmlEscapeMode.attribute).convert(link.toString());
    final label = const HtmlEscape().convert(doc.name);
    return '<a href="$href">$label</a>';
  }
}
