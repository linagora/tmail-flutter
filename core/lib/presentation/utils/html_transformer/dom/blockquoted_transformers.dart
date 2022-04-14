
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:html/dom.dart';

class BlockQuotedTransformer extends DomTransformer {

  const BlockQuotedTransformer();

  @override
  Future<void> process(
      Document document,
      String message,
      {
        Map<String, String>? mapUrlDownloadCID,
        DioClient? dioClient
      }
  ) async {
    final quotedElements = document.getElementsByTagName('blockquote');
    await Future.wait(quotedElements.map((quotedElement) async {
      quotedElement.attributes['style'] = '''
          margin-left: 4px;
          margin-right: 4px;
          padding-left: 8px;
          padding-right: 8px;
          border-left: 2px solid #eee;
        ''';
    }));
  }
}