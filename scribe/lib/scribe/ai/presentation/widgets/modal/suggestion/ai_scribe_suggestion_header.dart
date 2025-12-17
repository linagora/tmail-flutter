import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe/ai/presentation/styles/ai_scribe_styles.dart';

class AiScribeSuggestionHeader extends StatelessWidget {
  final String title;
  final ImagePaths imagePaths;

  const AiScribeSuggestionHeader({
    super.key,
    required this.title,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: Text(
            title,
            style: AIScribeTextStyles.suggestionTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TMailButtonWidget.fromIcon(
          icon: imagePaths.icCloseDialog,
          iconSize: 20,
          iconColor: AppColor.gray424244.withValues(alpha: 0.72),
          padding: const EdgeInsets.all(3),
          borderRadius: 20,
          backgroundColor: Colors.transparent,
          onTapActionCallback: Navigator.of(context).pop,
        )
      ],
    );
  }
}
