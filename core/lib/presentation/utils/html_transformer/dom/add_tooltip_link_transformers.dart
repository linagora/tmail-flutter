
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:html/dom.dart';

import '../html_template.dart';

class AddTooltipLinkTransformer extends DomTransformer {

  const AddTooltipLinkTransformer();

  @override
  Future<void> process(
      Document document,
      String message,
      {
        Map<String, String>? mapUrlDownloadCID,
        DioClient? dioClient
      }
  ) async {
    final linkElements = document.querySelectorAll('a[href^="http"]');
    await Future.wait(linkElements.map((linkElement) async {
      _addToolTipWhenHoverLink(linkElement);
    }));
  }

  void _addToolTipWhenHoverLink(Element element) {
    final url = element.attributes['href'];
    final text = element.text;
    final children = element.children;
    if (children.isEmpty && text.isNotEmpty && url != null) {
      final innerHtml = element.innerHtml;
      final tagClass = element.attributes['class'];
      element.attributes['class'] = '$tagClass $nameClassToolTip';
      element.innerHtml = innerHtml + textHasToolTip(url);
    }
  }

  String textHasToolTip(String url) {
    return '''
      <span class="tooltiptext">$url</span>
    ''';
  }
}