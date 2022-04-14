
/// Transforms plain text messages.
abstract class TextTransformer {
  const TextTransformer();

  String process(String text);
}