

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:html/dom.dart';

class ReplaceLazyLoadImageTransformer extends DomTransformer {

  const ReplaceLazyLoadImageTransformer();

  @override
  Future<void> process({
    required Document document,
    Map<String, String>? mapUrlDownloadCID,
    DioClient? dioClient
  }) async {
    final imageElements = document.querySelectorAll('img.lazy-loading');
    await Future.wait(imageElements.map((imageElement) async {
      final classAttribute = imageElement.attributes['class'];
      if (classAttribute != null) {
       final newClassAttribute = classAttribute.replaceFirst('lazy-loading', '');
       imageElement.attributes['class'] = newClassAttribute;
      }
      final dataSrc = imageElement.attributes['data-src'];
      if (dataSrc != null) {
        imageElement.attributes['src'] = dataSrc;
        imageElement.attributes.remove('data-src');
      }
      imageElement.attributes['loading'] = 'lazy';
    }));
  }
}