
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:html/dom.dart';

class AddTooltipLinkTransformer extends DomTransformer {

  const AddTooltipLinkTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
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
      if (tagClass != null) {
        element.attributes['class'] = '$tagClass ${HtmlTemplate.nameClassToolTip}';
      } else {
        element.attributes['class'] = HtmlTemplate.nameClassToolTip;
      }
      element.innerHtml = innerHtml + textHasToolTip(url);
    }
  }

  String textHasToolTip(String url) {
    return '''
      <span class="tooltiptext">$url</span>
    ''';
  }
}