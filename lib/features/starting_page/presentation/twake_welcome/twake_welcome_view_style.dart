import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';

class TwakeWelcomeViewStyle {
  static final TextStyle descriptionTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: LinagoraSysColors.material().onSurface
  );
}
