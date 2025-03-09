import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SettingExplanationWidget extends StatelessWidget {
  final AccountMenuItem menuItem;
  final EdgeInsetsGeometry? padding;

  const SettingExplanationWidget({
    Key? key,
    required this.menuItem,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: Text(
        menuItem.getExplanation(AppLocalizations.of(context)),
        style: ThemeUtils.textStyleBodyBody1(color: AppColor.steelGray400),
      ),
    );
  }
}