
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:html/dom.dart';

class SetStyleBlockQuoteTransformer extends DomTransformer {

  const SetStyleBlockQuoteTransformer();

  @override
  void process(Document document, String message, TransformConfiguration configuration) {
    final quoteElements = document.getElementsByTagName('blockquote');
    for (final quote in quoteElements) {
      final style = quote.attributes['style'];
      if (style == null) {
        quote.attributes['style'] = '''
          margin: 0px 8px 0px 8px;
          padding: 8px 16px 8px 16px;
          border-left:5px solid #eee;
        ''';
      }
    }
  }
}