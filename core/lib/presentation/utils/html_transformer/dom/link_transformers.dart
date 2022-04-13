
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';

class LinkTransformer extends DomTransformer {

  const LinkTransformer();

  @override
  Future<void> process(
      Document document,
      String message,
      Map<String, String>? mapUrlDownloadCID,
      DioClient dioClient
  ) async {
    final linkElements = document.getElementsByTagName('a');
    await Future.wait(linkElements.map((linkElement) async {
      linkElement.attributes['rel'] = 'noopener noreferrer';
      _addToolTipWhenHoverLink(linkElement);
    }));
  }

  void _addToolTipWhenHoverLink(Element element) {
    log('LinkTransformer::_addToolTipWhenHoverLink(): Before: ${element.outerHtml}');
    final url = element.attributes['href'];
    final text = element.text;
    final children = element.children;
    if (children.isEmpty && text.isNotEmpty && url?.isNotEmpty == true) {
      final innerHtml = element.innerHtml;
      final tagClass = element.attributes['class'];
      element.attributes['class'] = '$tagClass tooltip';
      if (text.isNotEmpty && url != null && url.isNotEmpty) {
        element.innerHtml = innerHtml + textHasToolTip(url);
      }
      log('LinkTransformer::_addToolTipWhenHoverLink(): After: ${element.outerHtml}');
    }
  }

  String textHasToolTip(String url) {
    return '''
      <span class="tooltiptext">$url</span>
    ''';
  }
}