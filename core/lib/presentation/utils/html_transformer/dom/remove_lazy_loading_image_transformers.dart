import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';

class RemoveLazyLoadingImageTransformer extends DomTransformer {
  const RemoveLazyLoadingImageTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      final elements = document.querySelectorAll('img[loading]');

      if (elements.isEmpty) return;

      await Future.wait(elements.map((element) async {
        element.attributes.remove('loading');
      }));
    } catch (e) {
      logError('$runtimeType::process:Exception = $e');
    }
  }
}
