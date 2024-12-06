
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';

class SettingDetailViewBuilder extends StatelessWidget {

  final ResponsiveUtils responsiveUtils;
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTapGestureDetector;

  const SettingDetailViewBuilder({
    super.key,
    required this.responsiveUtils,
    required this.child,
    this.padding,
    this.onTapGestureDetector
  });

  @override
  Widget build(BuildContext context) {
    Widget childWidget = Container(
      width: double.infinity,
      height: double.infinity,
      color: SettingsUtils.getContentBackgroundColor(context, responsiveUtils),
      decoration: SettingsUtils.getBoxDecorationForContent(context, responsiveUtils),
      margin: SettingsUtils.getMarginSettingDetailsView(context, responsiveUtils),
      padding: padding,
      child: child,
    );

    if (onTapGestureDetector != null) {
      childWidget = GestureDetector(
        onTap: onTapGestureDetector,
        child: childWidget,
      );
    }

    return Scaffold(
      backgroundColor: SettingsUtils.getBackgroundColor(context, responsiveUtils),
      body: childWidget,
    );
  }
}