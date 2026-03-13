import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scribe/scribe.dart';

class AiScribeModalManager {
  AiScribeModalManager._();

  static Future<void> showAIScribeModal({
    required bool isScribeMobile,
    required ImagePaths imagePaths,
    required List<AIScribeMenuCategory> availableCategories,
    required OnSelectAiScribeSuggestionAction onSelectAiScribeSuggestionAction,
    String? content,
    Offset? buttonPosition,
    Size? buttonSize,
    ModalPlacement? preferredPlacement,
    ModalCrossAxisAlignment crossAxisAlignment = ModalCrossAxisAlignment.center,
  }) async {
    final AIAction? aiAction = await showAIScribeMenuModal(
        isScribeMobile: isScribeMobile,
        imagePaths: imagePaths,
        content: content,
        availableCategories: availableCategories,
        buttonPosition: buttonPosition,
        buttonSize: buttonSize,
        preferredPlacement: preferredPlacement,
        crossAxisAlignment: crossAxisAlignment,
      );

    if (aiAction != null) {
      await showAIScribeSuggestionModal(
        aiAction: aiAction,
        isScribeMobile: isScribeMobile,
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

  static Future<AIAction?> showAIScribeMenuModal({
    required bool isScribeMobile,
    required ImagePaths imagePaths,
    required List<AIScribeMenuCategory> availableCategories,
    String? content,
    Offset? buttonPosition,
    Size? buttonSize,
    ModalPlacement? preferredPlacement,
    ModalCrossAxisAlignment crossAxisAlignment = ModalCrossAxisAlignment.center,
    bool showCustomPromptBar = true,
  }) async {
    if (isScribeMobile) {
      return await showMobileAIScribeMenuModal(
        imagePaths: imagePaths,
        content: content,
        availableCategories: availableCategories,
        showCustomPromptBar: showCustomPromptBar,
      );
    } else {
      return await showDesktopAIScribeMenuModal(
        imagePaths: imagePaths,
        content: content,
        availableCategories: availableCategories,
        buttonPosition: buttonPosition,
        buttonSize: buttonSize,
        preferredPlacement: preferredPlacement,
        crossAxisAlignment: crossAxisAlignment,
        showCustomPromptBar: showCustomPromptBar,
      );
    }
  }

  static Future<void> showAIScribeSuggestionModal({
    required AIAction aiAction,
    required bool isScribeMobile,
    required ImagePaths imagePaths,
    required OnSelectAiScribeSuggestionAction onSelectAiScribeSuggestionAction,
    String? content,
    Offset? buttonPosition,
    Size? buttonSize,
    ModalPlacement? preferredPlacement,
    ModalCrossAxisAlignment crossAxisAlignment = ModalCrossAxisAlignment.center,
  }) async {
    if (isScribeMobile) {
      await showMobileAIScribeSuggestionModal(
        aiAction: aiAction,
        imagePaths: imagePaths,
        content: content,
        onSelectAiScribeSuggestionAction: onSelectAiScribeSuggestionAction,
      );
    } else {
      await showDesktopAIScribeSuggestionModal(
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

  static Future<AIAction?> showDesktopAIScribeMenuModal({
    required ImagePaths imagePaths,
    required List<AIScribeMenuCategory> availableCategories,
    String? content,
    Offset? buttonPosition,
    Size? buttonSize,
    ModalPlacement? preferredPlacement,
    ModalCrossAxisAlignment crossAxisAlignment = ModalCrossAxisAlignment.center,
    bool showCustomPromptBar = true,
  }) async {
      final ContextSubmenuController submenuController = ContextSubmenuController();

      return await Get.dialog<AIAction>(
        AiScribeModalWidget(
          imagePaths: imagePaths,
          content: content,
          availableCategories: availableCategories,
          buttonPosition: buttonPosition,
          buttonSize: buttonSize,
          preferredPlacement: preferredPlacement,
          crossAxisAlignment: crossAxisAlignment,
          submenuController: submenuController,
          showCustomPromptBar: showCustomPromptBar,
        ),
        barrierColor: AIScribeColors.dialogBarrier,
      ).whenComplete(submenuController.dispose);
  }

  static Future<AIAction?> showMobileAIScribeMenuModal({
    required ImagePaths imagePaths,
    required List<AIScribeMenuCategory> availableCategories,
    String? content,
    bool showCustomPromptBar = true,
  }) async {
    final context = Get.context;

    if (context == null) return null;

    return await showModalBottomSheet<AIAction>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AiScribeMobileActionsBottomSheet(
        imagePaths: imagePaths,
        availableCategories: availableCategories,
        content: content,
        showCustomPromptBar: showCustomPromptBar,
      ),
    );
  }

  static Future<void> showDesktopAIScribeSuggestionModal({
    required AIAction aiAction,
    required ImagePaths imagePaths,
    required OnSelectAiScribeSuggestionAction onSelectAiScribeSuggestionAction,
    String? content,
    Offset? buttonPosition,
    Size? buttonSize,
    ModalPlacement? preferredPlacement,
    ModalCrossAxisAlignment crossAxisAlignment = ModalCrossAxisAlignment.center,
  }) async {
    await Get.dialog<void>(
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
      barrierColor: AIScribeColors.dialogBarrier,
    );
  }

  static Future<void> showMobileAIScribeSuggestionModal({
    required AIAction aiAction,
    required ImagePaths imagePaths,
    required OnSelectAiScribeSuggestionAction onSelectAiScribeSuggestionAction,
    String? content,
  }) async {
    final context = Get.context;

    if (context == null) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      builder: (context) => AiScribeMobileSuggestionBottomSheet(
        aiAction: aiAction,
        imagePaths: imagePaths,
        content: content,
        onSelectAction: onSelectAiScribeSuggestionAction,
      ),
    );
  }
}
