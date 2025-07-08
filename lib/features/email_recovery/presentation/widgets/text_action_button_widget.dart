import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/styles/text_action_button_widget_styles.dart';

class TextActionButtonWidget extends StatelessWidget {
  final Color colorButton;
  final Color colorText;
  final String text;
  final VoidCallback onAction;
  final double? minWidth;
  
  const TextActionButtonWidget({
    super.key,
    required this.colorButton,
    required this.colorText,
    required this.text,
    required this.onAction,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    return buildButtonWrapText(
      text,
      radius: TextActionButtonWidgetStyles.radius,
      height: TextActionButtonWidgetStyles.height,
      minWidth: minWidth,
      textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
        fontSize: TextActionButtonWidgetStyles.fontSize,
        color: colorText,
        fontWeight: FontWeight.w500
      ),
      bgColor: colorButton,
      onTap: onAction
    );
  }
}