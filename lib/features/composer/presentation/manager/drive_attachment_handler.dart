import 'dart:convert';

import 'package:core/presentation/extensions/media_type_extension.dart';
import 'package:core/presentation/model/file_category.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:http_parser/http_parser.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:workplace/domain/entity/drive_document.dart';

class DriveAttachmentHandler {
  DriveAttachmentHandler({required this.fileUtils});

  final FileUtils fileUtils;

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

  Future<String> buildDriveLinksHtml(
    List<DriveDocument> docs, {
    required ImagePaths imagePaths,
    AppLocalizations? appLocalizations,
    bool requireHttps = BuildUtils.isReleaseMode,
  }) async {
    final base64PngCache = <FileCategory, Future<String?>>{};
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
    return HtmlUtils.wrapFileCardsHtml(cards.nonNulls.join());
  }

  Future<String?> _driveFileCard(
    DriveDocument doc, {
    required bool requireHttps,
    required ImagePaths imagePath,
    required Map<FileCategory, Future<String?>> base64PngCache,
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

    return HtmlUtils.buildFileLinkCard(
      href: href,
      title: name,
      actionLabel: openInDriveLabel,
      iconZoneHtml: await _iconZoneHtml(
        category,
        imagePaths: imagePath,
        base64PngCache: base64PngCache,
      ),
    );
  }

  Future<String> _iconZoneHtml(
    FileCategory category, {
    required ImagePaths imagePaths,
    required Map<FileCategory, Future<String?>> base64PngCache,
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
    return HtmlUtils.buildFileCardIconZone(iconBase64Png: base64Png);
  }

  Future<String?> _cachedCategoryPngBase64(
    FileCategory category, {
    required ImagePaths imagePaths,
    required Map<FileCategory, Future<String?>> base64PngCache,
  }) {
    return base64PngCache.putIfAbsent(
      category,
      () => _loadCategoryPngBase64(category, imagePaths: imagePaths),
    );
  }

  Future<String?> _loadCategoryPngBase64(
    FileCategory category, {
    required ImagePaths imagePaths,
  }) async {
    final path = categoryPngPaths(imagePaths)[category];
    if (path == null) return null;
    try {
      final base64Data = await fileUtils.convertImageAssetToBase64(path);
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
