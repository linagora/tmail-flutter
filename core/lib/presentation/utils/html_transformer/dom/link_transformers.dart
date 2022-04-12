
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';

class EnsureRelationNoReferrerTransformer extends DomTransformer {

  const EnsureRelationNoReferrerTransformer();

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
      final tagClass = linkElement.attributes['class'];
      linkElement.attributes['class'] = '$tagClass tooltip';
      final url = linkElement.attributes['href'];
      final text = linkElement.text;
      if (url != null && url.isNotEmpty) {
        linkElement.innerHtml = textHasToolTip(text, url);
      }
      log('EnsureRelationNoReferrerTransformer::process(): ${linkElement.outerHtml}');
    }));
  }

  String textHasToolTip(String text, String? url) {
    return '''
      ${text.isNotEmpty ? text : url}
      <span class="tooltiptext">$url</span>
    ''';
  }
}