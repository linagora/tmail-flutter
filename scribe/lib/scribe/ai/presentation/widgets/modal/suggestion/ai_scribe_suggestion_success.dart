import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';
import 'package:scribe/scribe/ai/presentation/styles/ai_scribe_styles.dart';
import 'package:scribe/scribe/ai/presentation/widgets/modal/suggestion/ai_scribe_suggestion_success_list_actions.dart';

class AiScribeSuggestionSuccess extends StatelessWidget {
  final ImagePaths imagePaths;
  final String suggestionText;
  final AIAction aiAction;

  const AiScribeSuggestionSuccess({
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
          AiScribeSuggestionSuccessListActions(
            imagePaths: imagePaths,
            suggestionText: suggestionText,
            aiAction: aiAction,
          ),
        ],
      ),
    );
  }
}
