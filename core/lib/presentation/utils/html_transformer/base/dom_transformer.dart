
import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:html/dom.dart';

/// Transforms the HTML DOM.
abstract class DomTransformer {

  const DomTransformer();

  /// Uses the `DOM` [document] to transform the `document`.
  ///
  /// All changes will be visible to subsequent transformers.
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  });

  /// Adds a HEAD element if necessary
  void ensureDocumentHeadIsAvailable(Document document) {
    if (document.head == null) {
      document.children.insert(0, Element.html('<head></head>'));
    }
  }

  Tuple2<String, String>? findImageUrlFromStyleTag(String style) {
    try {
      final regExp = RegExp(r'background-image:\s*url\(([^)]+)\).*?');
      final match = regExp.firstMatch(style);
      if (match == null) {
        return null;
      }

      final backgroundImageUrl = match.group(0) ?? '';
      final imageUrl = match.group(1)?.replaceAll('\'', '').replaceAll('"', '') ?? '';
      if (backgroundImageUrl.isNotEmpty && imageUrl.isNotEmpty) {
        return Tuple2(backgroundImageUrl,  imageUrl);
      } else {
        return null;
      }
    } catch (e) {
      logError('DomTransformer::findImageUrlFromStyleTag:Exception: $e');
      return null;
    }
  }
}