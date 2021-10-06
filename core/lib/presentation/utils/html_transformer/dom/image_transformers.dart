
import 'package:html/dom.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';

class ImageTransformer extends DomTransformer {

  const ImageTransformer();

  @override
  void process(Document document, String message, TransformConfiguration configuration) {
    final imageElements = document.getElementsByTagName('img');
    for (final imageElement in imageElements) {
      final src = imageElement.attributes['src'];
      if (src != null) {
        if (src.startsWith('http')) {
          if (configuration.blockExternalImages) {
            imageElement.attributes.remove('src');
          } else if (src.startsWith('http:')) {
            // always at least enforce HTTPS images:
            final url = src.substring('http:'.length);
            imageElement.attributes['src'] = 'https:$url';
          }
        }
      }
      final style = imageElement.attributes['style'];
      if (style == null) {
        imageElement.attributes['style'] = 'display: inline;max-width: 100%;height: auto;';
      } else {
        imageElement.attributes['style'] = 'display: inline;max-width: 100%;height: auto;' + style;
      }
    }
  }
}