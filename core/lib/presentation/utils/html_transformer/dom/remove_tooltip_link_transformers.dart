
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/presentation/utils/html_transformer/html_template.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';

class RemoveTooltipLinkTransformer extends DomTransformer {

  const RemoveTooltipLinkTransformer();

  @override
  Future<void> process({
    required Document document,
    Map<String, String>? mapUrlDownloadCID,
    DioClient? dioClient
  }) async {
    final linkElements = document.querySelectorAll('a.$nameClassToolTip');
    await Future.wait(linkElements.map((linkElement) async {
      final classAttribute = linkElement.attributes['class'];
      if (classAttribute != null) {
        final newClassAttribute = classAttribute.replaceFirst(nameClassToolTip, '');
        linkElement.attributes['class'] = newClassAttribute;
      }
      final listSpanTag = linkElement.querySelectorAll('span.tooltiptext');
      log('RemoveTooltipLinkTransformer::process:listSpanTag: ${listSpanTag.length}');
      if (listSpanTag.isNotEmpty) {
        for (var element in listSpanTag) {
          element.remove();
        }
      }
    }));
  }

}