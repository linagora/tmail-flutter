
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';

class BlockQuotedTransformer extends DomTransformer {

  const BlockQuotedTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      final quotedElements = document.getElementsByTagName('blockquote');

      if (quotedElements.isEmpty) return;

      await Future.wait(quotedElements.map((quotedElement) async {
        quotedElement.attributes['style'] = '''
          margin-left: 4px;
          margin-right: 4px;
          padding-left: 8px;
          padding-right: 8px;
          border-left: 2px solid #eee;
        ''';
      }));
    } catch (e) {
      logError('$runtimeType::process:Exception = $e');
    }
  }
}