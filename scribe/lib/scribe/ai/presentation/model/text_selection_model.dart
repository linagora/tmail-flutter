import 'dart:ui' show Offset;

class TextSelectionModel {
  final String? selectedText;
  final Offset? coordinates;

  const TextSelectionModel({
    this.selectedText,
    this.coordinates,
  });

  bool get hasSelection => selectedText != null && selectedText!.isNotEmpty;
}
