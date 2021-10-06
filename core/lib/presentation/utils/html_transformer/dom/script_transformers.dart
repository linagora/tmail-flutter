
import 'package:html/dom.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';

class RemoveScriptTransformer extends DomTransformer {

  const RemoveScriptTransformer();

  @override
  void process(Document document, String message, TransformConfiguration configuration) {
    final scriptElements = document.getElementsByTagName('script');
    for (final scriptElement in scriptElements) {
      scriptElement.remove();
    }
  }
}