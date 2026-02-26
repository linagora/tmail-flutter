import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';

typedef OnSelectAiScribeSuggestionAction = void Function(
  AiScribeSuggestionActions action,
  String suggestionText,
);

class AiScribeSuggestionSuccessListActions extends StatelessWidget {
  final ImagePaths imagePaths;
  final String suggestionText;
  final bool hasContent;
  final OnSelectAiScribeSuggestionAction onSelectAction;
  final OnLoadSuggestion onLoadSuggestion;

  const AiScribeSuggestionSuccessListActions({
    super.key,
    required this.imagePaths,
    required this.suggestionText,
    required this.onSelectAction,
    required this.onLoadSuggestion,
    this.hasContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AIScribeSizes.successSpacing,
      children: [
        AiScribeSuggestionSuccessToolbar(suggestionText: suggestionText, onLoadSuggestion: onLoadSuggestion, imagePaths: imagePaths),
        AiScribeSuggestionSuccessActions(
          suggestionText: suggestionText,
          onLoadSuggestion: onLoadSuggestion,
          imagePaths: imagePaths,
          hasContent: hasContent,
          onSelectAction: onSelectAction,
        ),
      ],
    );
  }
}
