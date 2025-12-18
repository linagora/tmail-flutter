import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scribe/scribe.dart';

class AiScribeModalManager {
  AiScribeModalManager._();

  static Future<void> showAIScribeMenuModal({
    required ImagePaths imagePaths,
    required List<AIScribeMenuCategory> availableCategories,
    required OnSelectAiScribeSuggestionAction onSelectAiScribeSuggestionAction,
    String? content,
    Offset? buttonPosition,
    Size? buttonSize,
    ModalPlacement? preferredPlacement,
    ModalCrossAxisAlignment crossAxisAlignment = ModalCrossAxisAlignment.center,
  }) async {
    final PopupSubmenuController submenuController = PopupSubmenuController();

    final aiAction = await Get.dialog<AIAction>(
      AiScribeModalWidget(
        imagePaths: imagePaths,
        content: content,
        availableCategories: availableCategories,
        buttonPosition: buttonPosition,
        buttonSize: buttonSize,
        preferredPlacement: preferredPlacement,
        crossAxisAlignment: crossAxisAlignment,
        submenuController: submenuController,
      ),
      barrierColor: AIScribeColors.dialogBarrier,
    ).whenComplete(submenuController.dispose);

    if (aiAction != null) {
      await showAIScribeSuggestionModal(
        aiAction: aiAction,
        imagePaths: imagePaths,
        content: content,
        buttonPosition: buttonPosition,
        buttonSize: buttonSize,
        preferredPlacement: preferredPlacement,
        crossAxisAlignment: crossAxisAlignment,
        onSelectAiScribeSuggestionAction: onSelectAiScribeSuggestionAction,
      );
    }
  }

  static Future<void> showAIScribeSuggestionModal({
    required AIAction aiAction,
    required ImagePaths imagePaths,
    required OnSelectAiScribeSuggestionAction onSelectAiScribeSuggestionAction,
    String? content,
    Offset? buttonPosition,
    Size? buttonSize,
    ModalPlacement? preferredPlacement,
    ModalCrossAxisAlignment crossAxisAlignment = ModalCrossAxisAlignment.center,
  }) async {
    await Get.dialog<String?>(
      AiScribeSuggestionWidget(
        aiAction: aiAction,
        imagePaths: imagePaths,
        content: content,
        buttonPosition: buttonPosition,
        buttonSize: buttonSize,
        preferredPlacement: preferredPlacement,
        crossAxisAlignment: crossAxisAlignment,
        onSelectAiScribeSuggestionAction: onSelectAiScribeSuggestionAction,
      ),
      barrierDismissible: false,
      barrierColor: AIScribeColors.dialogBarrier,
    );
  }
}
