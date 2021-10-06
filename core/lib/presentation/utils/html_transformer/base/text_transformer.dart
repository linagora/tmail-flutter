
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';

/// Transforms plain text messages.
abstract class TextTransformer {
  const TextTransformer();

  String transform(String text, String message, TransformConfiguration configuration);
}