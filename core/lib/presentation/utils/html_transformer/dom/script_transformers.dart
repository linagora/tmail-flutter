
import 'package:core/data/network/dio_client.dart';
import 'package:html/dom.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';

class RemoveScriptTransformer extends DomTransformer {

  const RemoveScriptTransformer();

  @override
  Future<void> process(
      Document document,
      String message,
      Map<String, String>? mapUrlDownloadCID,
      TransformConfiguration configuration,
      DioClient dioClient
  ) async {
    final scriptElements = document.getElementsByTagName('script');
    await Future.wait(scriptElements.map((scriptElement) async {
      scriptElement.remove();
    }));
  }
}