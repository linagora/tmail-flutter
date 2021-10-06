
import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';

class LineBreakTextTransformer extends TextTransformer {

  const LineBreakTextTransformer();

  @override
  String transform(String text, String message, TransformConfiguration configuration) {
    text = text.replaceAll('\r\n', '<br/>');
    text = text.replaceAll('\n', '<br/>');
    return text;
  }
}