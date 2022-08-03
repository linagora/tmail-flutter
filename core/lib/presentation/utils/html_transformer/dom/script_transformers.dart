
import 'package:core/data/network/dio_client.dart';
import 'package:html/dom.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';

class RemoveScriptTransformer extends DomTransformer {

  const RemoveScriptTransformer();

  @override
  Future<void> process(
      Document document,
      {
        Map<String, String>? mapUrlDownloadCID,
        DioClient? dioClient
      }
  ) async {
    final scriptElements = document.getElementsByTagName('script');
    await Future.wait(scriptElements.map((scriptElement) async {
      scriptElement.remove();
    }));
  }
}