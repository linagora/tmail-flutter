import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';

class AddLazyLoadingForBackgroundImageTransformer extends DomTransformer {
  const AddLazyLoadingForBackgroundImageTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      final elements = document.querySelectorAll('[style*="background-image"]');

      if (elements.isEmpty) return;

      await Future.wait(elements.map((element) async {
        var exStyle = element.attributes['style'];
        final imageUrls = findImageUrlFromStyleTag(exStyle!);
        if (imageUrls != null) {
          exStyle = exStyle.replaceFirst(imageUrls.value1, '');
          element.attributes['style'] = exStyle;
          element.attributes['data-src'] = imageUrls.value2;
          element.attributes.addAll({'lazy': ''});
        }
      }));
    } catch (e) {
      logError('$runtimeType::process:Exception = $e');
    }
  }
}
