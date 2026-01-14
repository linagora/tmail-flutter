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
      logWarning('$runtimeType::getTextOnlyContentInEditor:Exception = $e');
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
      logWarning('$runtimeType::insertTextInEditor:Exception = $e');
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
      logWarning('$runtimeType::collapseSelection:Exception = $e');
    }
  }

  Future<bool> saveSelection() async {
    try {
      if (PlatformInfo.isWeb) {
        final result = await richTextWebController?.editorController.evaluateJavascriptWeb(
          HtmlUtils.saveSelection.name,
          hasReturnValue: true,
        ) ?? false;
        return result;
      } else {
        final result = await richTextMobileTabletController?.htmlEditorApi?.webViewController
            .evaluateJavascript(
          source: HtmlUtils.saveSelection.script,
        ) ?? false;
        return result;
      }
    } catch (e) {
      logError('$runtimeType::saveSelection:Exception = $e');
      return false;
    }
  }

  Future<bool> restoreSelection() async {
    try {
      if (PlatformInfo.isWeb) {
        final result = await richTextWebController?.editorController.evaluateJavascriptWeb(
          HtmlUtils.restoreSelection.name,
          hasReturnValue: true,
        ) ?? false;
        return result;
      } else {
        final result = await richTextMobileTabletController?.htmlEditorApi?.webViewController
            .evaluateJavascript(
          source: HtmlUtils.restoreSelection.script,
        ) ?? false;
        return result;
      }
    } catch (e) {
      logError('$runtimeType::restoreSelection:Exception = $e');
      return false;
    }
  }

  Future<void> clearSavedSelection() async {
    try {
      if (PlatformInfo.isWeb) {
        await richTextWebController?.editorController.evaluateJavascriptWeb(
          HtmlUtils.clearSavedSelection.name,
          hasReturnValue: false,
        );
      } else {
        await richTextMobileTabletController?.htmlEditorApi?.webViewController
            .evaluateJavascript(
          source: HtmlUtils.clearSavedSelection.script,
        );
      }
    } catch (e) {
      logError('$runtimeType::clearSavedSelection:Exception = $e');
    }
  }

  Future<void> unfocusEditor() async {
    final editorApi = richTextMobileTabletController?.htmlEditorApi;
    if (PlatformInfo.isIOS) {
      await editorApi?.unfocus();
    } else if (PlatformInfo.isAndroid) {
      await editorApi?.hideKeyboard();
      await editorApi?.unfocus();
    }
  }

  Future<void> saveAndUnfocusForModal() async {
    final saved = await saveSelection();
    if (saved) {
      await unfocusEditor();
    }
  }

  Future<void> ensureMobileEditorFocused() async {
    try {
      await richTextMobileTabletController?.focus();
    } catch (e) {
      logError('$runtimeType::ensureMobileEditorFocused:Exception = $e');
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
      logWarning('$runtimeType::clearTextInEditor:Exception = $e');
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

    if (PlatformInfo.isMobile) {
      await restoreSelection();
    }

    if (selection == null || selection.isEmpty) {
      clearTextInEditor();
    }

    await insertTextInEditor(text);
  }

  Future<void> openAIAssistantModal(Offset? position, Size? size) async {
    clearFocusRecipients();
    clearFocusSubject();

    if (PlatformInfo.isMobile) {
      await saveAndUnfocusForModal();
    }

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
    if (PlatformInfo.isMobile) {
      await ensureMobileEditorFocused();
    }

    switch (action) {
      case AiScribeSuggestionActions.replace:
        await onReplaceTextCallback(suggestionText);
        break;
      case AiScribeSuggestionActions.insert:
        await onInsertTextCallback(suggestionText);
        break;
    }

    if (PlatformInfo.isMobile) {
      await clearSavedSelection();
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
