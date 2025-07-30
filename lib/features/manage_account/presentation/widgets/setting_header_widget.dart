import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SettingHeaderWidget extends StatelessWidget {
  final AccountMenuItem menuItem;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const SettingHeaderWidget({
    Key? key,
    required this.menuItem,
    this.padding,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    final children = [
      Text(
        menuItem.getName(appLocalizations),
        style: textStyle ?? ThemeUtils.textStyleInter600().copyWith(
          color: Colors.black,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      if (menuItem.getExplanation(appLocalizations).isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 13),
          child: Text(
            menuItem.getExplanation(appLocalizations),
            style: ThemeUtils.textStyleInter400.copyWith(
              fontSize: 16,
              height: 21.01 / 16,
              letterSpacing: -0.15,
              color: AppColor.gray424244.withValues(alpha: 0.64),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
    ];

    final child = children.length == 1
        ? children.first
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children,
          );

    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}
