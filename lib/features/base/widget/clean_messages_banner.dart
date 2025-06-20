import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CleanMessagesBanner extends StatelessWidget {
  final ResponsiveUtils responsiveUtils;
  final String message;
  final String positiveAction;
  final VoidCallback onPositiveAction;
  final EdgeInsetsGeometry? margin;

  const CleanMessagesBanner({
    super.key,
    required this.responsiveUtils,
    required this.message,
    required this.positiveAction,
    required this.onPositiveAction,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final displayPositiveActionIsNewLine = (PlatformInfo.isMobile &&
              responsiveUtils.isPortraitMobile(context)) ||
          (PlatformInfo.isWeb &&
              (responsiveUtils.isTabletLarge(context) ||
                  responsiveUtils.isMobile(context)));

      final textStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
            color: AppColor.steelGray400,
          );
      final actionStyle = ThemeUtils.textStyleInter700(
        color: AppColor.blue700,
        fontSize: 14,
      );
      const horizontalPadding = 16;
      final maxWidth = constraints.maxWidth - horizontalPadding;
      const maxLines = 3;
      String finalMessage = message;
      late double maxMessageWidth;
      String actionText = positiveAction;

      if (displayPositiveActionIsNewLine) {
        actionText = ' $positiveAction';
        final actionTp = TextPainter(
          text: TextSpan(text: actionText, style: actionStyle),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout(maxWidth: maxWidth);
        maxMessageWidth = maxWidth - actionTp.width;
      } else {
        maxMessageWidth = maxWidth;
      }

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

      Widget contentWidget = displayPositiveActionIsNewLine
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16),
                  child: Text(
                    finalMessage,
                    maxLines: maxLines,
                    style: textStyle,
                  ),
                ),
                const SizedBox(height: 4),
                TMailButtonWidget.fromText(
                  text: actionText,
                  textStyle: actionStyle,
                  backgroundColor: Colors.transparent,
                  margin: EdgeInsetsDirectional.only(
                    start: PlatformInfo.isMobile ? 6 : 4,
                  ),
                  onTapActionCallback: onPositiveAction,
                ),
              ],
            )
          : Text.rich(
              TextSpan(
                style: textStyle,
                children: [
                  TextSpan(text: '$finalMessage '),
                  TextSpan(
                    text: actionText,
                    style: actionStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = onPositiveAction,
                  ),
                ],
              ),
              maxLines: maxLines,
              overflow: TextOverflow.clip,
            );

      return Container(
        decoration: BoxDecoration(
          color: AppColor.m3LayerDarkOutline.withOpacity(0.08),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        padding: displayPositiveActionIsNewLine
          ? const EdgeInsetsDirectional.only(
              top: 16,
              bottom: 8,
              end: 16,
            )
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        margin: margin,
        alignment: displayPositiveActionIsNewLine
          ? AlignmentDirectional.centerStart
          : Alignment.center,
        child: contentWidget,
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
