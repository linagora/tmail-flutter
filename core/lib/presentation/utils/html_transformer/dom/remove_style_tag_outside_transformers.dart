import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:html/dom.dart';

class RemoveStyleTagOutsideTransformer extends DomTransformer {

  const RemoveStyleTagOutsideTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    final styleElements = document.querySelectorAll('style');
    await Future.wait(styleElements.map((element) async {
      element.remove();
    }));
  }
}