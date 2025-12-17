import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_action.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_scribe_menu_action.dart';
import 'package:scribe/scribe/ai/presentation/model/modal/modal_cross_axis_alignment.dart';
import 'package:scribe/scribe/ai/presentation/model/modal/modal_placement.dart';
import 'package:scribe/scribe/ai/presentation/styles/ai_scribe_styles.dart';
import 'package:scribe/scribe/ai/presentation/utils/context_menu/popup_submenu_controller.dart';
import 'package:scribe/scribe/ai/presentation/widgets/modal/ai_scribe_modal_widget.dart';
import 'package:scribe/scribe/ai/presentation/widgets/modal/ai_scribe_suggestion_widget.dart';

class AiScribeModalManager {
  AiScribeModalManager._();

  static Future<String?> showAIScribeMenuModal({
    required ImagePaths imagePaths,
    required List<AIScribeMenuCategory> availableCategories,
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
    ).whenComplete(submenuController.hide);

    if (aiAction != null) {
      return await showAIScribeSuggestionModal(
        aiAction: aiAction,
        imagePaths: imagePaths,
        content: content,
        buttonPosition: buttonPosition,
        buttonSize: buttonSize,
      );
    }

    return null;
  }

  static Future<String?> showAIScribeSuggestionModal({
    required AIAction aiAction,
    required ImagePaths imagePaths,
    String? content,
    Offset? buttonPosition,
    Size? buttonSize,
  }) {
    return Get.dialog<String?>(
      AiScribeSuggestionWidget(
        aiAction: aiAction,
        imagePaths: imagePaths,
        content: content,
        buttonPosition: buttonPosition,
        buttonSize: buttonSize,
      ),
      barrierColor: AIScribeColors.dialogBarrier,
    );
  }
}
