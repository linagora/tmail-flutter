import 'dart:convert';

import 'package:core/presentation/extensions/media_type_extension.dart';
import 'package:core/presentation/model/file_category.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:core/utils/file_utils.dart';
import 'package:http_parser/http_parser.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:workplace/domain/entity/drive_document.dart';

class DriveAttachmentHandler {
  const DriveAttachmentHandler();

  static const _cardWidthPx = 183;
  static const _cardMinHeightPx = 151;
  static const _iconZoneHeightPx = 94;
  static const _iconSizePx = 60;
  static const _fallbackOpenInDriveLabel = 'Open in drive';

  static Map<FileCategory, String> categoryPngPaths(ImagePaths imagePaths) => {
    FileCategory.image: imagePaths.icDriveImage,
    FileCategory.other: imagePaths.icDriveOther,
  };

  Future<void> handleDrivePickResult(
    List<DriveDocument> result, {
    required void Function(String html) insertHtml,
    required ImagePaths imagePaths,
    AppLocalizations? appLocalizations,
  }) async {
    final linkDocs = result.where((doc) => doc.sharingLink != null).toList();
    await insertDriveLinkHtml(
      linkDocs,
      insertHtml: insertHtml,
      imagePaths: imagePaths,
      appLocalizations: appLocalizations,
    );
  }

  Future<void> insertDriveLinkHtml(
    List<DriveDocument> docs, {
    required void Function(String html) insertHtml,
    required ImagePaths imagePaths,
    AppLocalizations? appLocalizations,
  }) async {
    insertHtml(
      await buildDriveLinksHtml(
        docs,
        imagePaths: imagePaths,
        appLocalizations: appLocalizations,
      ),
    );
  }

  static Future<String> buildDriveLinksHtml(
    List<DriveDocument> docs, {
    required ImagePaths imagePaths,
    AppLocalizations? appLocalizations,
    bool requireHttps = BuildUtils.isReleaseMode,
  }) async {
    final base64PngCache = <FileCategory, String?>{};
    final cards = await Future.wait(
      docs.map(
        (doc) => _driveFileCard(
          doc,
          requireHttps: requireHttps,
          imagePath: imagePaths,
          appLocalizations: appLocalizations,
          base64PngCache: base64PngCache,
        ),
      ),
    );
    final nonNullCards = cards.nonNulls.join();
    if (nonNullCards.isEmpty) return '';
    return '<div style="display:block;max-width:100%;">$nonNullCards</div><br>';
  }

  static Future<String?> _driveFileCard(
    DriveDocument doc, {
    required bool requireHttps,
    required ImagePaths imagePath,
    required Map<FileCategory, String?> base64PngCache,
    AppLocalizations? appLocalizations,
  }) async {
    final link = doc.sharingLink;
    if (link == null) return null;
    if (requireHttps && !link.isScheme('https')) return null;

    final href = const HtmlEscape(
      HtmlEscapeMode.attribute,
    ).convert(link.toString());
    final name = const HtmlEscape().convert(doc.name);
    final openInDriveLabel = const HtmlEscape().convert(
      appLocalizations?.openInDrive ?? _fallbackOpenInDriveLabel,
    );
    final category = _resolveCategory(doc);

    return '<a href="$href" style="display:inline-block;vertical-align:top;width:${_cardWidthPx}px;'
        'min-height:${_cardMinHeightPx}px;margin:0 8px 8px 0;border:1px solid #E5E7EB;'
        'border-radius:10px;overflow:hidden;background:#FFFFFF;color:inherit;text-decoration:none;">'
        '${await _iconZoneHtml(category, imagePaths: imagePath, base64PngCache: base64PngCache)}'
        '<div style="padding:10px 12px;">'
        '<div style="font-size:14px;font-weight:500;color:#1F2937;white-space:nowrap;'
        'overflow:hidden;text-overflow:ellipsis;" title="$name">$name</div>'
        '<div style="display:block;margin-top:6px;font-size:12px;'
        'color:#0A84FF;white-space:nowrap;overflow:hidden;'
        'text-overflow:ellipsis;">$openInDriveLabel ↗</div>'
        '</div>'
        '</a>';
  }

  static Future<String> _iconZoneHtml(
    FileCategory category, {
    required ImagePaths imagePaths,
    required Map<FileCategory, String?> base64PngCache,
  }) async {
    final base64Png =
        await _cachedCategoryPngBase64(
          category,
          imagePaths: imagePaths,
          base64PngCache: base64PngCache,
        ) ??
        await _cachedCategoryPngBase64(
          FileCategory.other,
          imagePaths: imagePaths,
          base64PngCache: base64PngCache,
        );
    final content = base64Png != null
        ? '<img src="data:image/png;base64,$base64Png" width="$_iconSizePx" height="$_iconSizePx" '
              'style="display:inline-block;vertical-align:middle;" />'
        : '';
    return '<div style="height:${_iconZoneHeightPx}px;line-height:${_iconZoneHeightPx}px;'
        'text-align:center;background:#F5F6F8;border-bottom:1px solid #E5E7EB;">'
        '$content'
        '</div>';
  }

  static Future<String?> _cachedCategoryPngBase64(
    FileCategory category, {
    required ImagePaths imagePaths,
    required Map<FileCategory, String?> base64PngCache,
  }) async {
    if (base64PngCache.containsKey(category)) {
      return base64PngCache[category];
    }
    final base64Png = await _loadCategoryPngBase64(
      category,
      imagePaths: imagePaths,
    );
    base64PngCache[category] = base64Png;
    return base64Png;
  }

  static Future<String?> _loadCategoryPngBase64(
    FileCategory category, {
    required ImagePaths imagePaths,
  }) async {
    final path = categoryPngPaths(imagePaths)[category];
    if (path == null) return null;
    try {
      final base64Data = await FileUtils().convertImageAssetToBase64(path);
      return base64Data.isNotEmpty ? base64Data : null;
    } catch (e) {
      logWarning(
        'DriveAttachmentHandler::_loadCategoryPngBase64:Exception: $e',
      );
      return null;
    }
  }

  static FileCategory _resolveCategory(DriveDocument doc) {
    try {
      return MediaType.parse(doc.mimeType).getFileCategory(fileName: doc.name);
    } on FormatException {
      return FileCategory.other;
    }
  }
}
