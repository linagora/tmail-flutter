import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/string_convert.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';
import 'package:scribe/scribe/ai/presentation/model/modal/modal_cross_axis_alignment.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/text_selection_mixin.dart';

extension HandleAiScribeInComposerExtension on ComposerController {
  bool get isAIScribeAvailable {
    return isAICapabilitySupported(
      session: mailboxDashBoardController.sessionCurrent,
      accountId: mailboxDashBoardController.accountId.value,
    );
  }

  Future<String> _getTextOnlyContentInEditor() async {
    try {
      final htmlContent = await getContentInEditor();
      String textContent = StringConvert.convertHtmlContentToTextContent(
        htmlContent,);
      return textContent;
    } catch (e) {
      logError('$runtimeType::getTextOnlyContentInEditor:Exception = $e');
      return '';
    }
  }

  void insertTextInEditor(String text) {
    final htmlContent = text.replaceAll('\n', '<br>');

    if (PlatformInfo.isWeb) {
      richTextWebController?.editorController.insertHtml(htmlContent);
    } else {
      richTextMobileTabletController?.htmlEditorApi?.insertHtml(htmlContent);
    }
  }

  Future<void> openAIAssistantModal(Offset? position, Size? size) async {
    final fullText = await _getTextOnlyContentInEditor();

    final aiResult = await AiScribeModalManager.showAIScribeMenuModal(
      imagePaths: imagePaths,
      availableCategories: AIScribeMenuCategory.values,
      buttonPosition: position,
      buttonSize: size,
      content: fullText,
      preferredPlacement: ModalPlacement.top,
      crossAxisAlignment: ModalCrossAxisAlignment.start,
    );

    if (aiResult != null) {
      insertTextInEditor(aiResult);
    }
  }

  void handleTextSelection(TextSelectionData? textSelectionData) {
    if (textSelectionData != null && textSelectionData.hasSelection) {
      editorTextSelection.value = TextSelectionModel(
        selectedText: textSelectionData.selectedText,
        coordinates: textSelectionData.coordinates != null
            ? Offset(
          textSelectionData.coordinates!.x,
          textSelectionData.coordinates!.y,
        )
            : null,
      );
    } else {
      editorTextSelection.value = null;
    }
  }
}
