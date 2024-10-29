
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';

class BlockCodeTransformer extends DomTransformer {

  const BlockCodeTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      final codeElements = document.getElementsByTagName('pre');

      if (codeElements.isEmpty) return;

      await Future.wait(codeElements.map((element) async {
        element.attributes['style'] = '''
          display: block;
          padding: 10px;
          margin: 0 0 10px;
          font-size: 13px;
          line-height: 1.5;
          color: #333;
          word-break: break-all;
          word-wrap: break-word;
          background-color: #f5f5f5;
          border: 1px solid #ccc;
          border-radius: 4px;
          overflow: auto;
        ''';
      }));
    } catch (e) {
      logError('$runtimeType::process:Exception = $e');
    }
  }
}