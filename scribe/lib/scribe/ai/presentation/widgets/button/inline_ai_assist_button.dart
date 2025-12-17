import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_scribe_menu_action.dart';
import 'package:scribe/scribe/ai/presentation/styles/ai_scribe_styles.dart';
import 'package:scribe/scribe/ai/presentation/utils/modal/ai_scribe_modal_manager.dart';
import 'package:scribe/scribe/ai/presentation/widgets/modal/suggestion/ai_scribe_suggestion_success_list_actions.dart';

class InlineAiAssistButton extends StatelessWidget {
  final ImagePaths imagePaths;
  final String? selectedText;
  final OnSelectAiScribeSuggestionAction onSelectAiScribeSuggestionAction;

  const InlineAiAssistButton({
    super.key,
    required this.imagePaths,
    required this.onSelectAiScribeSuggestionAction,
    this.selectedText,
  });

  @override
  Widget build(BuildContext context) {
    return TMailButtonWidget.fromIcon(
      icon: imagePaths.icSparkle,
      padding: AIScribeSizes.scribeButtonPadding,
      backgroundColor: AIScribeColors.background,
      iconSize: AIScribeSizes.scribeIcon,
      iconColor: AIScribeColors.scribeIcon,
      borderRadius: AIScribeSizes.scribeButtonRadius,
      boxShadow: AIScribeShadows.sparkleIcon,
      onTapActionCallback: () => _onTapActionCallback(context),
    );
  }

  Future<void> _onTapActionCallback(BuildContext context) async {
    final renderBox = context.findRenderObject();

    Offset? position;
    Size? size;

    if (renderBox != null && renderBox is RenderBox) {
      position = renderBox.localToGlobal(Offset.zero);
      size = renderBox.size;
    }

    await AiScribeModalManager.showAIScribeMenuModal(
      imagePaths: imagePaths,
      availableCategories: AIScribeMenuCategory.values,
      buttonPosition: position,
      content: selectedText,
      buttonSize: size,
      onSelectAiScribeSuggestionAction: onSelectAiScribeSuggestionAction,
    );
  }
}
