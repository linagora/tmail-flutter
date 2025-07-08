import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class TryAgainButton extends StatelessWidget {
  const TryAgainButton({
    super.key,
    required this.onRetry,
    required this.responsiveUtils,
  });

  final VoidCallback onRetry;
  final ResponsiveUtils responsiveUtils;

  @override
  Widget build(BuildContext context) {
    return TMailButtonWidget.fromText(
      text: AppLocalizations.of(context).tryAgain,
      textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
        fontSize: 16,
        color: Colors.white,
      ),
      backgroundColor: AppColor.primaryColor,
      onTapActionCallback: onRetry,
      borderRadius: 10,
      margin: const EdgeInsetsDirectional.only(bottom: 16, start: 24, end: 24),
      width: responsiveUtils.getDeviceWidth(context),
      textAlign: TextAlign.center,
      padding: const EdgeInsets.symmetric(vertical: 12),
    );
  }
}