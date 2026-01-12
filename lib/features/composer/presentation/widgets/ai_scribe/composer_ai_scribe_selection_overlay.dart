import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/platform_info.dart';
import 'package:scribe/scribe/ai/presentation/widgets/overlay/ai_selection_overlay.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/ai_scribe/handle_ai_scribe_in_composer_extension.dart';

class ComposerAiScribeSelectionOverlay extends StatelessWidget {
  const ComposerAiScribeSelectionOverlay({
    super.key,
    required this.controller,
  });

  final ComposerController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.isAIScribeAvailable) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      return AiSelectionOverlay(
        selection: controller.editorTextSelection.value,
        imagePaths: controller.imagePaths,
        onSelectAiScribeSuggestionAction:
            controller.handleAiScribeSuggestionAction,
        onTapFallback: _clearComposerInputFocus,
      );
    });
  }

  Future<void> _clearComposerInputFocus() async {
    controller.clearFocusRecipients();
    controller.clearFocusSubject();

    if (PlatformInfo.isMobile) {
      await controller.saveAndUnfocusForModal();
    }
  }
}
