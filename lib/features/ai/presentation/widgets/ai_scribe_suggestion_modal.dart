import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/ai/presentation/styles/ai_scribe_styles.dart';
import 'package:tmail_ui_user/features/ai/presentation/widgets/ai_scribe_suggestion.dart';

class AIScribeSuggestionModal extends StatelessWidget {
  final String suggestion;
  final VoidCallback onClose;
  final VoidCallback onInsert;
  final ImagePaths imagePaths;

  const AIScribeSuggestionModal({
    super.key,
    required this.suggestion,
    required this.onClose,
    required this.onInsert,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PointerInterceptor(
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(AIScribeSizes.menuBorderRadius),
          child: Container(
            width: 500,
            constraints: const BoxConstraints(
              maxHeight: 400,
              minHeight: 200,
            ),
            decoration: BoxDecoration(
              color: AIScribeColors.background,
              borderRadius: BorderRadius.circular(AIScribeSizes.menuBorderRadius),
              boxShadow: AIScribeShadows.elevation8,
            ),
            child: AIScribeSuggestion(
              suggestion: suggestion,
              onClose: onClose,
              onInsert: onInsert,
              imagePaths: imagePaths,
            ),
          ),
        ),
      ),
    );
  }
}
