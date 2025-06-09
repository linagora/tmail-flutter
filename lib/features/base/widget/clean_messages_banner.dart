import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CleanMessagesBanner extends StatelessWidget {
  final String message;
  final String positiveAction;
  final VoidCallback onPositiveAction;
  final EdgeInsetsGeometry? margin;

  const CleanMessagesBanner({
    super.key,
    required this.message,
    required this.positiveAction,
    required this.onPositiveAction,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final textStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
            color: AppColor.steelGray400,
          );
      final actionStyle = ThemeUtils.textStyleInter700(
        color: AppColor.blue700,
        fontSize: 14,
      );

      final actionText = ' $positiveAction';

      const horizontalPadding = 16;
      final maxWidth = constraints.maxWidth - horizontalPadding;
      const maxLines = 3;

      final actionTp = TextPainter(
        text: TextSpan(text: actionText, style: actionStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: maxWidth);

      final maxMessageWidth = maxWidth - actionTp.width;

      String finalMessage = message;

      TextPainter messageTp = _buildMessageTp(
        finalMessage,
        textStyle,
        maxLines,
        maxMessageWidth,
      );

      if (messageTp.didExceedMaxLines) {
        finalMessage = _truncateMiddle(
          finalMessage,
          textStyle,
          maxMessageWidth,
          maxLines,
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: AppColor.m3LayerDarkOutline.withOpacity(0.08),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        margin: margin,
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            style: textStyle,
            children: [
              TextSpan(text: '$finalMessage '),
              TextSpan(
                text: actionText,
                style: actionStyle,
                recognizer: TapGestureRecognizer()..onTap = onPositiveAction,
              ),
            ],
          ),
          maxLines: maxLines,
          overflow: TextOverflow.clip,
        ),
      );
    });
  }

  TextPainter _buildMessageTp(
    String text,
    TextStyle style,
    int maxLines,
    double maxWidth,
  ) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth);
  }

  String _truncateMiddle(
    String text,
    TextStyle style,
    double maxWidth,
    int maxLines,
  ) {
    const ellipsis = '...';
    int left = 0;
    int right = text.length;

    while (left < right) {
      final mid = ((right - left) ~/ 2) + left;
      final leftStr = text.substring(0, mid ~/ 2);
      final rightStr = text.substring(text.length - mid ~/ 2);
      final display = '$leftStr$ellipsis$rightStr';
      final tp = _buildMessageTp(display, style, maxLines, maxWidth);
      if (tp.didExceedMaxLines) {
        right = mid;
      } else {
        left = mid + 1;
      }
    }

    final leftStr = text.substring(0, left ~/ 2);
    final rightStr = text.substring(text.length - left ~/ 2);
    return '$leftStr$ellipsis$rightStr';
  }
}
