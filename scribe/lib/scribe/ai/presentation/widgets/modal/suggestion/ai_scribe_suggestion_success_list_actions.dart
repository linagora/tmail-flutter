import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';

typedef OnSelectAiScribeSuggestionAction = void Function(
  AiScribeSuggestionActions action,
  String suggestionText,
);

class AiScribeSuggestionSuccessListActions extends StatelessWidget {
  final ImagePaths imagePaths;
  final String suggestionText;
  final OnSelectAiScribeSuggestionAction onSelectAction;

  const AiScribeSuggestionSuccessListActions({
    super.key,
    required this.imagePaths,
    required this.suggestionText,
    required this.onSelectAction,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = ScribeLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 8,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(minWidth: 67),
            height: 36,
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
        ),
        Flexible(
          child: Container(
            constraints: const BoxConstraints(minWidth: 72),
            height: 36,
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
        ),
      ],
    );
  }
}
