import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';
import 'package:scribe/scribe/ai/presentation/styles/ai_scribe_styles.dart';

class AiScribeSuggestionSuccessListActions extends StatelessWidget {
  final ImagePaths imagePaths;
  final String suggestionText;
  final AIAction aiAction;

  const AiScribeSuggestionSuccessListActions({
    super.key,
    required this.imagePaths,
    required this.suggestionText,
    required this.aiAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              suggestionText,
              style: AIScribeTextStyles.suggestionContent,
            ),
          ),
        ],
      ),
    );
  }
}
