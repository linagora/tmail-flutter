import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:html/dom.dart';

class AddTargetBlankInTagATransformer extends DomTransformer {
  const AddTargetBlankInTagATransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    final elements = document.querySelectorAll('a');
    await Future.wait(elements.map((element) async {
      element.attributes['target'] = '_blank';
      final rel = element.attributes['rel'];
      if (rel == null || (!rel.contains('noopener') && !rel.contains('noreferrer'))) {
        element.attributes['rel'] = 'noreferrer';
      }
    }));
  }
}
