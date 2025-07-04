import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SettingExplanationWidget extends StatelessWidget {
  final AccountMenuItem menuItem;
  final EdgeInsetsGeometry? padding;
  final bool isCenter;

  const SettingExplanationWidget({
    Key? key,
    required this.menuItem,
    this.isCenter = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget child = Text(
      menuItem.getExplanation(AppLocalizations.of(context)),
      style: ThemeUtils.textStyleM3BodyMedium1
          .copyWith(color: AppColor.gray424244.withOpacity(0.64)),
    );

    if (isCenter) {
      child = Center(child: child);
    }

    if (padding != null) {
      child = Padding(padding: padding!, child: child);
    }

    return child;
  }
}
