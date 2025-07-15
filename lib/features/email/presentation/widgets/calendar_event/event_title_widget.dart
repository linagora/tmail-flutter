
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/event_title_widget_styles.dart';

class EventTitleWidget extends StatelessWidget {

  final String title;

  const EventTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: ThemeUtils.defaultTextStyleInterFont.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: EventTitleWidgetStyles.textSize,
        color: EventTitleWidgetStyles.textColor
      )
    );
  }
}