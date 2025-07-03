
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';

class SettingDetailViewBuilder extends StatelessWidget {

  final ResponsiveUtils responsiveUtils;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;
  final VoidCallback? onTapGestureDetector;

  const SettingDetailViewBuilder({
    super.key,
    required this.responsiveUtils,
    required this.child,
    this.padding,
    this.backgroundColor = Colors.white,
    this.onTapGestureDetector
  });

  @override
  Widget build(BuildContext context) {
    Widget containerWidget = Container(
      width: double.infinity,
      height: double.infinity,
      color: SettingsUtils.getContentBackgroundColor(
        context,
        responsiveUtils,
        backgroundColor: backgroundColor,
      ),
      decoration: SettingsUtils.getBoxDecorationForContent(
        context,
        responsiveUtils,
        backgroundColor: backgroundColor,
      ),
      margin: SettingsUtils.getMarginSettingDetailsView(
        context,
        responsiveUtils,
      ),
      padding: padding,
      child: child,
    );

    if (onTapGestureDetector != null) {
      containerWidget = GestureDetector(
        onTap: onTapGestureDetector,
        child: containerWidget,
      );
    }

    return Scaffold(
      backgroundColor: SettingsUtils.getBackgroundColor(
        context,
        responsiveUtils,
      ),
      body: containerWidget,
    );
  }
}