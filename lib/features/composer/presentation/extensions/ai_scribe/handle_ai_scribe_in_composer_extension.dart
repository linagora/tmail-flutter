import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/string_convert.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/text_selection_mixin.dart';

extension HandleAiScribeInComposerExtension on ComposerController {
  bool get isAIScribeAvailable {
    final isAIScribeEndpointAvailable =
        mailboxDashBoardController.isAIScribeEndpointAvailable(
      session: mailboxDashBoardController.sessionCurrent,
      accountId: mailboxDashBoardController.accountId.value,
    );

    final isAIScribeConfigEnabled =
        mailboxDashBoardController.cachedAIScribeConfig.value.isEnabled;

    return isAIScribeConfigEnabled && isAIScribeEndpointAvailable;
  }

  Future<String> _getTextOnlyContentInEditor() async {
    try {
      final htmlContent = await getContentInEditor();
      String textContent = StringConvert.convertHtmlContentToTextContent(
        htmlContent,
      );
      return textContent;
    } catch (e) {
      logError('$runtimeType::getTextOnlyContentInEditor:Exception = $e');
      return '';
    }
  }

  Future<void> insertTextInEditor(String text) async {
    try {
      final htmlContent = StringConvert.convertTextContentToHtmlContent(text);

      if (PlatformInfo.isWeb) {
        await richTextWebController?.editorController.evaluateJavascriptWeb(
          HtmlUtils.deleteSelectionContent.name,
          hasReturnValue: false,
        );

        richTextWebController?.editorController.insertHtml(htmlContent);
      } else {
        richTextMobileTabletController?.htmlEditorApi?.insertHtml(htmlContent);
      }
    } catch (e) {
      logError('$runtimeType::insertTextInEditor:Exception = $e');
    }
  }

  Future<void> collapseSelection() async {
    try {
      if (PlatformInfo.isWeb) {
        await richTextWebController?.editorController.evaluateJavascriptWeb(
          HtmlUtils.collapseSelectionToEnd.name,
          hasReturnValue: false,
        );
      } else {
        await richTextMobileTabletController?.htmlEditorApi?.webViewController
            .evaluateJavascript(
          source: HtmlUtils.collapseSelectionToEnd.script,
        );
      }
    } catch (e) {
      logError('$runtimeType::collapseSelection:Exception = $e');
    }
  }

  void clearTextInEditor() {
    try {
      if (PlatformInfo.isWeb) {
        richTextWebController?.editorController.setText('');
      } else {
        richTextMobileTabletController?.htmlEditorApi?.setText('');
      }
    } catch (e) {
      logError('$runtimeType::clearTextInEditor:Exception = $e');
    }
  }

  // Ensure we only insert at cursor position by collapsing selection before inserting
  Future<void> onInsertTextCallback(String text) async {
    await collapseSelection();
    await insertTextInEditor(text);
  }

  // If there is a selection, it will replace the selection, else it will replace everything
  Future<void> onReplaceTextCallback(String text) async {
    final selection = editorTextSelection.value?.selectedText;
    if (selection == null || selection.isEmpty) {
      clearTextInEditor();
    }

    await insertTextInEditor(text);
  }

  Future<void> openAIAssistantModal(Offset? position, Size? size) async {
    clearFocusRecipients();
    clearFocusSubject();

    final fullText = await _getTextOnlyContentInEditor();

    await AiScribeModalManager.showAIScribeMenuModal(
      imagePaths: imagePaths,
      availableCategories: AIScribeMenuCategory.values,
      buttonPosition: position,
      buttonSize: size,
      content: fullText,
      preferredPlacement: ModalPlacement.top,
      crossAxisAlignment: ModalCrossAxisAlignment.start,
      onSelectAiScribeSuggestionAction: handleAiScribeSuggestionAction,
    );
  }

  Future<void> handleAiScribeSuggestionAction(
    AiScribeSuggestionActions action,
    String suggestionText,
  ) async {
    switch (action) {
      case AiScribeSuggestionActions.replace:
        await onReplaceTextCallback(suggestionText);
        break;
      case AiScribeSuggestionActions.insert:
        await onInsertTextCallback(suggestionText);
        break;
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

  void Function(TextSelectionData? textSelectionData)?
      get textSelectionHandler =>
          isAIScribeAvailable ? handleTextSelection : null;
}
