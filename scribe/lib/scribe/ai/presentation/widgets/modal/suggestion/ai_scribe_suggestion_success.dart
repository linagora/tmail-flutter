import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';

class AiScribeSuggestionSuccess extends StatelessWidget {
  final ImagePaths imagePaths;
  final String suggestionText;
  final bool hasContent;
  final OnSelectAiScribeSuggestionAction onSelectAction;
  final VoidCallback onLoadSuggestion;

  const AiScribeSuggestionSuccess({
    super.key,
    required this.imagePaths,
    required this.suggestionText,
    required this.onSelectAction,
    required this.onLoadSuggestion,
    this.hasContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: SelectableText(
                  suggestionText,
                  style: AIScribeTextStyles.suggestionContent,
                ),
              ),
            ),
          ),
          AiScribeSuggestionSuccessListActions(
            imagePaths: imagePaths,
            suggestionText: suggestionText,
            hasContent: hasContent,
            onSelectAction: onSelectAction,
            onLoadSuggestion: onLoadSuggestion,
          ),
        ],
      ),
    );
  }
}
