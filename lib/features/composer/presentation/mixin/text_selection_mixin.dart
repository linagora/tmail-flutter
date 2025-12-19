import 'package:flutter/material.dart';

typedef OnTextSelectionChanged = Function(TextSelectionData?);

class TextSelectionData {
  final bool hasSelection;
  final String? selectedText;
  final TextSelectionCoordinates? coordinates;

  const TextSelectionData({
    required this.hasSelection,
    this.selectedText,
    this.coordinates,
  });

  factory TextSelectionData.empty() {
    return const TextSelectionData(hasSelection: false);
  }

  factory TextSelectionData.fromMap(Map<dynamic, dynamic> data) {
    try {
      final hasSelection = data['hasSelection'] as bool? ?? false;

      if (!hasSelection) {
        return TextSelectionData.empty();
      }

      final selectedText = data['selectedText'] as String?;
      final coordinatesData = data['coordinates'];

      if (coordinatesData != null && selectedText != null) {
        final coordinates = TextSelectionCoordinates.fromMap(coordinatesData);
        return TextSelectionData(
          hasSelection: true,
          selectedText: selectedText,
          coordinates: coordinates,
        );
      }

      return TextSelectionData.empty();
    } catch (e) {
      return TextSelectionData.empty();
    }
  }
}

class TextSelectionCoordinates {
  final double x;
  final double y;
  final double width;
  final double height;

  const TextSelectionCoordinates({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory TextSelectionCoordinates.fromMap(Map<dynamic, dynamic> data) {
    try {
      return TextSelectionCoordinates(
        x: (data['x'] as num?)?.toDouble() ?? 0.0,
        y: (data['y'] as num?)?.toDouble() ?? 0.0,
        width: (data['width'] as num?)?.toDouble() ?? 0.0,
        height: (data['height'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      return const TextSelectionCoordinates(
        x: 0.0,
        y: 0.0,
        width: 0.0,
        height: 0.0,
      );
    }
  }

  Offset get position => Offset(x, y);
}

mixin TextSelectionMixin<T extends StatefulWidget> on State<T> {
  OnTextSelectionChanged? get onSelectionChanged => null;

  void handleSelectionChange(Map<dynamic, dynamic> data) {
    final selectionData = TextSelectionData.fromMap(data);
    onSelectionChanged?.call(selectionData);
  }
}
