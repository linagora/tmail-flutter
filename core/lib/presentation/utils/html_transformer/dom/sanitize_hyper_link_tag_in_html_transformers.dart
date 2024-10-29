import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/presentation/utils/html_transformer/sanitize_url.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:html/dom.dart';

class SanitizeHyperLinkTagInHtmlTransformer extends DomTransformer {
  final _sanitizeUrl = SanitizeUrl();
  final bool useTooltip;

  SanitizeHyperLinkTagInHtmlTransformer({this.useTooltip = false});

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      final elements = document.querySelectorAll('a');

      if (elements.isEmpty) return;

      await Future.wait(elements.map((element) async {
        _sanitizeUrlResource(element);
        if (useTooltip) {
          _addToolTipWhenHoverLink(element);
        }
        _addBlankForTargetProperty(element);
        _addNoReferrerForRelProperty(element);
      }));
    } catch (e) {
      logError('$runtimeType::process:Exception = $e');
    }
  }

  void _sanitizeUrlResource(Element element) {
    final url = element.attributes['href'] ?? '';

    final urlSanitized = _sanitizeUrl.process(url);
    if (urlSanitized.isEmpty) {
      return;
    }

    element.attributes['href'] = urlSanitized;
  }

  void _addToolTipWhenHoverLink(Element element) {
    final url = element.attributes['href'] ?? '';
    final text = element.text;
    final children = element.children;
    if (children.isEmpty && text.isNotEmpty) {
      final innerHtml = element.innerHtml;
      final tagClass = element.attributes['class'];
      if (tagClass != null) {
        element.attributes['class'] = '$tagClass ${HtmlTemplate.nameClassToolTip}';
      } else {
        element.attributes['class'] = HtmlTemplate.nameClassToolTip;
      }
      element.innerHtml = '$innerHtml <span class="tooltiptext">$url</span>';
    }
  }

  void _addBlankForTargetProperty(Element element) {
    element.attributes['target'] = '_blank';
  }

  void _addNoReferrerForRelProperty(Element element) {
    final rel = element.attributes['rel'];
    if (rel == null || (!rel.contains('noopener') && !rel.contains('noreferrer'))) {
      element.attributes['rel'] = 'noreferrer';
    }
  }
}
