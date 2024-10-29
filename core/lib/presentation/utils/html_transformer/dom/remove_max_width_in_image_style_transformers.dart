import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';

class RemoveMaxWidthInImageStyleTransformer extends DomTransformer {

  const RemoveMaxWidthInImageStyleTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      final imageElements = document.querySelectorAll('img[style*="max-width"]');

      if (imageElements.isEmpty) return;

      await Future.wait(imageElements.map((imageElement) async {
        var exStyle = imageElement.attributes['style'];
        if (exStyle != null) {
          exStyle = exStyle.replaceAll('max-width:100%;', '');
          imageElement.attributes['style'] = exStyle;
        }
      }));
    } catch (e) {
      logError('$runtimeType::process:Exception = $e');
    }
  }
}