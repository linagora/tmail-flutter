import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:scribe/scribe.dart';
import 'package:scribe/scribe/ai/presentation/widgets/ai_scribe.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_mobile_tablet_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mixins/text_selection_mixin.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';

mixin AIScribeInComposerMixin {
  final editorTextSelection = Rxn<EditorTextSelection>();
  final GlobalKey aiScribeButtonKey = GlobalKey();

  RichTextWebController? get richTextWebController;
  RichTextMobileTabletController? get richTextMobileTabletController;
  ImagePaths get imagePaths;
  GenerateAITextInteractor get generateAITextInteractor;
  Session? get session;
  AccountId? get accountId;

  bool get isAIScribeAvailable {
    final currentSession = session;
    final currentAccountId = accountId;

    if (currentSession == null || currentAccountId == null) return false;

    final aiCapability = currentSession.getAICapability(currentAccountId);
    return aiCapability != null;
  }

  Future<String> getTextOnlyContentInEditor();

  void insertTextInEditor(String text) {
    final htmlContent = text.replaceAll('\n', '<br>');

    if (PlatformInfo.isWeb) {
      richTextWebController?.editorController.insertHtml(htmlContent);
    } else {
      richTextMobileTabletController?.htmlEditorApi?.insertHtml(htmlContent);
    }
  }

  void showAIScribeMenuForFullText(BuildContext context) async {
    final fullText = await getTextOnlyContentInEditor();

    final RenderBox? renderBox = aiScribeButtonKey.currentContext?.findRenderObject() as RenderBox?;
    Offset? buttonPosition;
    if (renderBox != null) {
      buttonPosition = renderBox.localToGlobal(Offset.zero);
    }

    if (!context.mounted) return;

    showAIScribeDialog(
      context: context,
      imagePaths: imagePaths,
      content: fullText,
      onInsertText: insertTextInEditor,
      interactor: generateAITextInteractor,
      buttonPosition: buttonPosition,
    );
  }

  void showAIScribeMenuForSelectedText(BuildContext context, {Offset? buttonPosition}) {
    final selection = editorTextSelection.value?.selectedText;
    if (selection == null || selection.isEmpty) {
      return;
    }

    showAIScribeDialog(
      context: context,
      imagePaths: imagePaths,
      content: selection,
      onInsertText: insertTextInEditor,
      interactor: generateAITextInteractor,
      buttonPosition: buttonPosition,
    );
  }

  void handleTextSelection(TextSelectionData? textSelectionData) {
    if (textSelectionData != null && textSelectionData.hasSelection) {
      editorTextSelection.value = EditorTextSelection(
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
