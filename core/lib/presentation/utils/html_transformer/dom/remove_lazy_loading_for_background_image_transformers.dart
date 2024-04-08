import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:html/dom.dart';

class RemoveLazyLoadingForBackgroundImageTransformer extends DomTransformer {
  const RemoveLazyLoadingForBackgroundImageTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    final elements = document.querySelectorAll('[lazy]');
    await Future.wait(elements.map((element) async {
      var exStyle = element.attributes['style'];
      final dataSrc = element.attributes['data-src'];
      final backgroundImgUrl = 'background-image:url($dataSrc);';
      if (exStyle != null) {
        exStyle = '$exStyle;$backgroundImgUrl';
        element.attributes['style'] = exStyle;
      } else {
        element.attributes['style'] = backgroundImgUrl;
      }
      element.attributes.remove('data-src');
      element.attributes.remove('lazy');
    }));
  }
}
