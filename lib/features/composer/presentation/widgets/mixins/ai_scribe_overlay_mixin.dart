import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/ai/presentation/model/ai_scribe_menu_action.dart';
import 'package:tmail_ui_user/features/ai/presentation/widgets/ai_scribe_button.dart';

typedef AIScribeActionCallback = void Function(AIScribeMenuAction);
typedef TextSelectionChangedCallback = void Function(String?);

mixin AIScribeOverlayMixin<T extends StatefulWidget> on State<T> {
  OverlayEntry? _aiScribeButtonOverlay;
  OverlayEntry? _aiScribeMenuOverlay;

  ImagePaths? get aiScribeImagePaths;

  AIScribeActionCallback? get aiScribeActionCallback;

  TextSelectionChangedCallback? get textSelectionChangedCallback;

  Widget buildAIScribeMenu({
    required BuildContext context,
    required AIScribeActionCallback onActionSelected,
  });

  void disposeAIScribeOverlays() {
    hideAIScribeButton();
    hideAIScribeMenu();
  }

  void onSelectionChanged(
    bool hasSelection,
    String? selectedText,
    Map<String, double>? coordinates,
  ) {
    if (hasSelection && selectedText != null && selectedText.isNotEmpty) {
      textSelectionChangedCallback?.call(selectedText);
      showAIScribeButton(coordinates);
    } else {
      textSelectionChangedCallback?.call(null);
      hideAIScribeButton();
      hideAIScribeMenu();
    }
  }

  void parseSelectionData(Map<dynamic, dynamic> data) {
    try {
      final hasSelection = data['hasSelection'] as bool? ?? false;

      if (hasSelection) {
        final selectedText = data['selectedText'] as String?;
        final coordinatesData = data['coordinates'];

        if (coordinatesData != null) {
          final x = (coordinatesData['x'] as num?)?.toDouble();
          final y = (coordinatesData['y'] as num?)?.toDouble();
          final width = (coordinatesData['width'] as num?)?.toDouble();
          final height = (coordinatesData['height'] as num?)?.toDouble();

          if (selectedText != null && x != null && y != null) {
            final coordinates = {
              'x': x,
              'y': y,
              'width': width ?? 0.0,
              'height': height ?? 0.0,
            };
            onSelectionChanged(true, selectedText, coordinates);
            return;
          }
        }
      }

      onSelectionChanged(false, null, null);
    } catch (e) {
      onSelectionChanged(false, null, null);
    }
  }

  void showAIScribeButton(Map<String, double>? coordinates) {
    hideAIScribeButton();

    if (coordinates == null ||
        aiScribeActionCallback == null ||
        aiScribeImagePaths == null) {
      return;
    }

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final editorPosition = renderBox.localToGlobal(Offset.zero);

    _aiScribeButtonOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: editorPosition.dx + coordinates['x']! + 8,
        top: editorPosition.dy + coordinates['y']! + 8,
        child: buildAIScribeButtonWrapper(
          context: context,
          child: AIScribeButton(
            imagePaths: aiScribeImagePaths!,
            onTap: () {
              showAIScribeMenu(coordinates);
            },
          ),
        ),
      ),
    );

    overlay.insert(_aiScribeButtonOverlay!);
  }

  void hideAIScribeButton() {
    _aiScribeButtonOverlay?.remove();
    _aiScribeButtonOverlay = null;
  }

  void showAIScribeMenu(Map<String, double>? coordinates) {
    hideAIScribeMenu();

    if (coordinates == null) return;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final editorPosition = renderBox.localToGlobal(Offset.zero);

    final menuLeft = editorPosition.dx + coordinates['x']! + 8;
    final menuTop = editorPosition.dy +
        coordinates['y']! +
        40; // 24 (button height) + 16 (spacing)

    _aiScribeMenuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: menuLeft,
        top: menuTop,
        child: buildAIScribeMenu(
          context: context,
          onActionSelected: (action) {
            hideAIScribeMenu();
            hideAIScribeButton();
            aiScribeActionCallback?.call(action);
          },
        ),
      ),
    );

    overlay.insert(_aiScribeMenuOverlay!);
  }

  void hideAIScribeMenu() {
    _aiScribeMenuOverlay?.remove();
    _aiScribeMenuOverlay = null;
  }

  Widget buildAIScribeButtonWrapper({
    required BuildContext context,
    required Widget child,
  }) {
    return child;
  }
}
