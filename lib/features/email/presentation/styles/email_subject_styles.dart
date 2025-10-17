import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class EmailSubjectStyles {
  static int? maxLines = PlatformInfo.isWeb ? 2 : null;

  static const EdgeInsetsGeometry padding = EdgeInsets.all(16);
  static const EdgeInsetsGeometry mobilePadding = EdgeInsets.all(12);

  static final TextStyle textStyle = ThemeUtils.textStyleInter500().copyWith(
    overflow: PlatformInfo.isWeb ? TextOverflow.ellipsis : null,
    color: Colors.black,
    fontSize: 24,
    letterSpacing: -0.24,
  );
}