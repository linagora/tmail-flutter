
import 'package:core/core.dart';
import 'package:html/dom.dart';

/// Transforms the HTML DOM.
abstract class DomTransformer {

  const DomTransformer();

  /// Uses the `DOM` [document] to transform the `document`.
  ///
  /// All changes will be visible to subsequent transformers.
  Future<void> process(
      Document document,
      {
        Map<String, String>? mapUrlDownloadCID,
        DioClient? dioClient,
      }
  );

  /// Adds a HEAD element if necessary
  void ensureDocumentHeadIsAvailable(Document document) {
    if (document.head == null) {
      document.children.insert(0, Element.html('<head></head>'));
    }
  }
}