import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';

class AiScribeMobileSuggestionBottomSheet extends StatefulWidget {
  final AIAction aiAction;
  final ImagePaths imagePaths;
  final String? content;
  final OnSelectAiScribeSuggestionAction onSelectAction;

  const AiScribeMobileSuggestionBottomSheet({
    super.key,
    required this.aiAction,
    required this.imagePaths,
    required this.onSelectAction,
    this.content,
  });

  @override
  State<AiScribeMobileSuggestionBottomSheet> createState() =>
      _AiScribeMobileSuggestionBottomSheetState();
}

class _AiScribeMobileSuggestionBottomSheetState
    extends State<AiScribeMobileSuggestionBottomSheet>
    with AiScribeSuggestionStateMixin {
  @override
  AIAction get aiAction => widget.aiAction;

  @override
  String? get content => widget.content;

  @override
  ImagePaths get imagePaths => widget.imagePaths;

  @override
  OnSelectAiScribeSuggestionAction get onSelectAction =>
      widget.onSelectAction;

  @override
  Widget build(BuildContext context) {
    final localizations = ScribeLocalizations.of(context);

    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AIScribeColors.background,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: AIScribeSizes.suggestionHeaderPadding,
              child: AiScribeSuggestionHeader(
                title: widget.aiAction.getLabel(localizations),
                imagePaths: widget.imagePaths,
              ),
            ),
            Flexible(
              child: buildStateContent(context, localizations),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildLoadingState(ScribeLocalizations localizations) {
    return Padding(
      padding: AIScribeSizes.suggestionContentPadding,
      child: super.buildLoadingState(localizations),
    );
  }

  @override
  Widget buildErrorState(ScribeLocalizations localizations) {
    return Padding(
      padding: AIScribeSizes.suggestionContentPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          super.buildErrorState(localizations),
        ],
      ),
    );
  }

  @override
  Widget buildSuccessState(
    String suggestionText,
    bool hasContent,
    ScribeLocalizations localizations,
  ) {
    return Padding(
      padding: AIScribeSizes.suggestionContentPadding,
      child: super.buildSuccessState(suggestionText, hasContent, localizations),
    );
  }
}
