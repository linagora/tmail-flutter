
import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';

class RemoveScriptTransformer extends DomTransformer {

  const RemoveScriptTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      final scriptElements = document.getElementsByTagName('script');

      if (scriptElements.isEmpty) return;

      await Future.wait(scriptElements.map((scriptElement) async {
        scriptElement.remove();
      }));
    } catch (e) {
      logError('$runtimeType::process:Exception = $e');
    }
  }
}