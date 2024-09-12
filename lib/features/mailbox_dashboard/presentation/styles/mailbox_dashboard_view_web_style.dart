
import 'package:flutter/cupertino.dart';

class MailboxDashboardViewWebStyle {
  static const SizedBox searchFilterSizeBoxMargin = SizedBox(width: 8);

  static EdgeInsetsGeometry getSearchFilterButtonPadding(bool isSelected) {
    if (isSelected) {
      return const EdgeInsetsDirectional.only(start: 12, end: 4);
    } else {
      return const EdgeInsets.symmetric(horizontal: 12);
    }
  }
}