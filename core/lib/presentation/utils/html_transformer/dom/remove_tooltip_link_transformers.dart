
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:html/dom.dart';

class RemoveTooltipLinkTransformer extends DomTransformer {

  const RemoveTooltipLinkTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      final linkElements = document.querySelectorAll('a.${HtmlTemplate.nameClassToolTip}');

      if (linkElements.isEmpty) return;

      await Future.wait(linkElements.map((linkElement) async {
        final classAttribute = linkElement.attributes['class'];
        if (classAttribute != null) {
          final newClassAttribute = classAttribute.replaceFirst(HtmlTemplate.nameClassToolTip, '');
          linkElement.attributes['class'] = newClassAttribute;
        }
        final listSpanTag = linkElement.querySelectorAll('span.tooltiptext');
        if (listSpanTag.isNotEmpty) {
          for (var element in listSpanTag) {
            element.remove();
          }
        }
      }));
    } catch (e) {
      logError('$runtimeType::process:Exception = $e');
    }
  }

}