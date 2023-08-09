
import 'package:core/utils/platform_info.dart';
import 'package:flutter/cupertino.dart';

class TrailingMailboxItemWidgetStyles {
  static const double menuIconSize = 20;

  static const EdgeInsetsGeometry countEmailsPadding = EdgeInsetsDirectional.only(start: PlatformInfo.isWeb ? 10 : 12);
  static const EdgeInsetsGeometry menuIconPadding = EdgeInsetsDirectional.only(start: 8);
}