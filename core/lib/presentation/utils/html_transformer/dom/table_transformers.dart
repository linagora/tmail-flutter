
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:html/dom.dart';

class SetStyleTableTransformer extends DomTransformer {

  const SetStyleTableTransformer();

  @override
  void process(Document document, String message, TransformConfiguration configuration) {
    final tableElements = document.getElementsByTagName('table');
    for (final table in tableElements) {
      final style = table.attributes['style'];
      if (style == null) {
        table.attributes['style'] = 'width: 100%;max-width: 100%;border:1px solid #f0f0f0;border-collapse: collapse;border-spacing: 2px;';
      }
    }

    final tdElements = document.getElementsByTagName('td');
    for (final tdTag in tdElements) {
      final style = tdTag.attributes['style'];
      if (style == null) {
        tdTag.attributes['style'] = 'padding: 13px;margin: 0px;border:1px solid #f0f0f0;';
      }
    }

    final thElements = document.getElementsByTagName('th');
    for (final thTag in thElements) {
      final style = thTag.attributes['style'];
      if (style == null) {
        thTag.attributes['style'] = 'padding: 13px;margin: 0px;border:1px solid #f0f0f0;';
      }
    }
  }
}