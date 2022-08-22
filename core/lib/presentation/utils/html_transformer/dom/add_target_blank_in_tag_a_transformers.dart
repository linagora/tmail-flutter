import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:html/dom.dart';

class AddTargetBlankInTagATransformer extends DomTransformer {
  const AddTargetBlankInTagATransformer();

  @override
  Future<void> process(
    Document document, {
    Map<String, String>? mapUrlDownloadCID,
    DioClient? dioClient,
  }) async {
    final elements = document.querySelectorAll('a');
    await Future.wait(elements.map((element) async {
      element.attributes['target'] = '_blank';
    }));
  }
}
