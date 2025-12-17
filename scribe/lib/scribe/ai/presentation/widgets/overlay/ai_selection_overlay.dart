import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:scribe/scribe/ai/presentation/model/text_selection_model.dart';
import 'package:scribe/scribe/ai/presentation/widgets/button/inline_ai_assist_button.dart';
import 'package:scribe/scribe/ai/presentation/widgets/modal/suggestion/ai_scribe_suggestion_success_list_actions.dart';

class AiSelectionOverlay extends StatelessWidget {
  const AiSelectionOverlay({
    super.key,
    required this.selection,
    required this.imagePaths,
    required this.onSelectAiScribeSuggestionAction,
  });

  final TextSelectionModel? selection;
  final ImagePaths imagePaths;
  final OnSelectAiScribeSuggestionAction onSelectAiScribeSuggestionAction;

  @override
  Widget build(BuildContext context) {
    if (selection == null ||
        !selection!.hasSelection ||
        selection!.coordinates == null) {
      return const SizedBox.shrink();
    }

    final coordinates = selection!.coordinates!;
    final selectedText = selection!.selectedText;

    return PositionedDirectional(
      start: coordinates.dx,
      top: coordinates.dy,
      child: PointerInterceptor(
        child: InlineAiAssistButton(
          imagePaths: imagePaths,
          selectedText: selectedText,
          onSelectAiScribeSuggestionAction: onSelectAiScribeSuggestionAction,
        ),
      ),
    );
  }
}
