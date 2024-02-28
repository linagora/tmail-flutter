import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:html/dom.dart';

class RemoveTagHiddenTransformer extends DomTransformer {
  const RemoveTagHiddenTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    final elements = document.querySelectorAll('[style]');
    await Future.wait(elements.map((element) async {
      var exStyle = element.attributes['style'];
      if (exStyle?.contains('display: none') == true || exStyle?.contains('display:none') == true) {
        element.remove();
      }
    }));
  }
}
