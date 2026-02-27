import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';

class AiScribeSuggestionSuccessActions extends StatelessWidget {
  final ImagePaths imagePaths;
  final String suggestionText;
  final bool hasContent;
  final OnSelectAiScribeSuggestionAction onSelectAction;
  final OnLoadSuggestion onLoadSuggestion;

  const AiScribeSuggestionSuccessActions({
    super.key,
    required this.imagePaths,
    required this.suggestionText,
    required this.onSelectAction,
    required this.onLoadSuggestion,
    this.hasContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AiScribeImproveButton(
          imagePaths: imagePaths,
          suggestionText: suggestionText,
          onLoadSuggestion: onLoadSuggestion,
        ),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hasContent) _buildReplaceButton(context),
              _buildInsertButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReplaceButton(BuildContext context) {
    final localizations = ScribeLocalizations.of(context);
    return Flexible(
      child: Container(
        constraints: const BoxConstraints(minWidth: AIScribeSizes.minButtonWidth),
        height: AIScribeSizes.buttonHeight,
        child: ConfirmDialogButton(
          label: AiScribeSuggestionActions.replace.getLabel(localizations),
          textColor: AppColor.primaryMain,
          onTapAction: () {
            Navigator.of(context).pop();
            onSelectAction(
              AiScribeSuggestionActions.replace,
              suggestionText,
            );
          },
        ),
      ),
    );
  }

  Widget _buildInsertButton(BuildContext context) {
    final localizations = ScribeLocalizations.of(context);
    return Flexible(
      child: Container(
        constraints: const BoxConstraints(minWidth: AIScribeSizes.minButtonWidth),
        height: AIScribeSizes.buttonHeight,
        child: ConfirmDialogButton(
          label: AiScribeSuggestionActions.insert.getLabel(localizations),
          backgroundColor: AppColor.blueD2E9FF,
          textColor: AppColor.primaryMain,
          onTapAction: () {
            Navigator.of(context).pop();
            onSelectAction(
              AiScribeSuggestionActions.insert,
              suggestionText,
            );
          },
        ),
      ),
    );
  }
}