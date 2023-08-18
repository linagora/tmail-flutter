
import 'dart:convert';

/// Transforms plain text messages.
abstract class TextTransformer {
  const TextTransformer();

  String process(String text, HtmlEscape htmlEscape);
}