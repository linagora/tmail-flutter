import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scribe/scribe.dart';
import 'package:core/presentation/resources/image_paths.dart';

class AiScribeSuggestionSuccessToolbar extends StatelessWidget {
  final String suggestionText;
  final VoidCallback onLoadSuggestion;
  final ImagePaths imagePaths;

  const AiScribeSuggestionSuccessToolbar({
    super.key,
    required this.suggestionText,
    required this.onLoadSuggestion,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TMailButtonWidget.fromIcon(
          icon: imagePaths.icCopy,
          iconSize: AIScribeSizes.icon,
          iconColor: AIScribeColors.secondaryIcon,
          backgroundColor: Colors.transparent,
          tooltipMessage: ScribeLocalizations.of(context).copy,
          onTapActionCallback: () {
            Clipboard.setData(ClipboardData(text: suggestionText));
          },
        ),
        TMailButtonWidget.fromIcon(
          icon: imagePaths.icRefresh,
          iconSize: AIScribeSizes.icon,
          iconColor: AIScribeColors.secondaryIcon,
          backgroundColor: Colors.transparent,
          tooltipMessage: ScribeLocalizations.of(context).retry,
          onTapActionCallback: onLoadSuggestion,
        ),
      ],
    );
  }
}