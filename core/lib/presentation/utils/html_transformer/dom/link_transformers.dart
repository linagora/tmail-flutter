
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:html/dom.dart';

class EnsureRelationNoReferrerTransformer extends DomTransformer {

  const EnsureRelationNoReferrerTransformer();

  @override
  void process(Document document, String message, TransformConfiguration configuration) {
    final linkElements = document.getElementsByTagName('a');
    for (final linkElement in linkElements) {
      linkElement.attributes['rel'] = 'noopener noreferrer';
    }
  }
}