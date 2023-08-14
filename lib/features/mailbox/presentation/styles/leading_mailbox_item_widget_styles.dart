
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/cupertino.dart';

class LeadingMailboxItemWidgetStyles {
  static const double expandIconSize = 15;
  static const double expandIconSplashRadius = 12;
  static const double emptyBoxSize = 32;

  static const Color displayColor = AppColor.primaryColor;
  static const Color normalColor = AppColor.colorIconUnSubscribedMailbox;

  static const EdgeInsetsGeometry expandIconPadding = EdgeInsetsDirectional.only(start: 8);

  static Matrix4 mailboxIconTransform(BuildContext context) => Matrix4.translationValues(
    DirectionUtils.isDirectionRTLByLanguage(context) ? 0.0 : -4.0,
    0.0,
    0.0
  );
}