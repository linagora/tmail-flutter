
import 'package:html/dom.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';

class BlockQuotedTransformer extends DomTransformer {

  const BlockQuotedTransformer();

  @override
  void process(Document document, String message, TransformConfiguration configuration) {
    final quotedElements = document.getElementsByTagName('blockquote');
    for (final quotedElement in quotedElements) {
      quotedElement.attributes['style'] = '''
          margin-left: 4px;
          margin-right: 4px;
          padding-left: 8px;
          padding-right: 8px;
          border-left: 2px solid #eee;
        ''';
    }
  }
}