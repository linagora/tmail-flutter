
import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';

class ConvertTagsTextTransformer implements TextTransformer {

  const ConvertTagsTextTransformer();

  @override
  String transform(String text, String message, TransformConfiguration configuration) {
    return text.replaceAll('<', '&lt;').replaceAll('>', '&gt;');
  }
}