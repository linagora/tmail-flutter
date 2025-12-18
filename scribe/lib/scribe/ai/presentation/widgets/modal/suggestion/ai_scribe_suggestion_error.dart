import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scribe/scribe.dart';

class AiScribeSuggestionError extends StatelessWidget {
  final ImagePaths imagePaths;

  const AiScribeSuggestionError({
    super.key,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8, start: 8),
      child: Row(
        spacing: 8,
        children: [
          SvgPicture.asset(
            imagePaths.icWarning,
            width: 22,
            height: 22,
          ),
          Expanded(
            child: Text(
              ScribeLocalizations.of(context).failedToGenerate,
              style: AIScribeTextStyles.suggestionLoading,
            ),
          ),
        ],
      ),
    );
  }
}
