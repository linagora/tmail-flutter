
import 'package:core/data/network/dio_client.dart';
import 'package:html/dom.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';

class MetaTransformer extends DomTransformer {

  static final Element _viewPortMetaElement = Element.html(
    '<meta name="viewport" content="width=device-width, initial-scale=1.0">');
  static final Element _contentTypeMetaElement = Element.html(
    '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">');

  const MetaTransformer();

  @override
  Future<void> process(
      Document document,
      String message,
      Map<String, String>? mapUrlDownloadCID,
      DioClient dioClient
  ) async {
    final metaElements = document.getElementsByTagName('meta');
    var viewportNeedsToBeAdded = true;
    var contentTypeNeedsToBeAdded = true;

    await Future.wait(metaElements.map((metaElement) async {
      if (metaElement.attributes['name'] == 'viewport') {
        viewportNeedsToBeAdded = false;
        metaElement.attributes['content'] = 'width=device-width, initial-scale=1.0';
      } else if (metaElement.attributes['charset'] != null) {
        metaElement.attributes['charset'] = 'utf-8';
      } else {
        final httpEquiv = metaElement.attributes['http-equiv'];
        if (httpEquiv != null && httpEquiv.toLowerCase() == 'content-type') {
          contentTypeNeedsToBeAdded = false;
          metaElement.attributes['content'] = 'text/html; charset=utf-8';
        }
      }
    }));

    if (contentTypeNeedsToBeAdded) {
      ensureDocumentHeadIsAvailable(document);
      document.head!.append(_contentTypeMetaElement);
    }
    if (viewportNeedsToBeAdded) {
      ensureDocumentHeadIsAvailable(document);
      document.head!.append(_viewPortMetaElement);
    }
  }
}