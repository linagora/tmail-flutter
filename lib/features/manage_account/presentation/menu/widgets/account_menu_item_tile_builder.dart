import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSelectAccountMenuItemAction = void Function(AccountMenuItem);

class AccountMenuItemTileBuilder extends StatelessWidget {

  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final AccountMenuItem menuItem;
  final AccountMenuItem? menuItemSelected;
  final EdgeInsetsGeometry? padding;
  final OnSelectAccountMenuItemAction onSelectAccountMenuItemAction;

  const AccountMenuItemTileBuilder({
    Key? key,
    required this.imagePaths,
    required this.responsiveUtils,
    required this.menuItem,
    required this.onSelectAccountMenuItemAction,
    this.menuItemSelected,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: Key('${menuItem.getAliasBrowser()}_account_menu_item_tile'),
      padding: padding ?? const EdgeInsets.only(top: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelectAccountMenuItemAction.call(menuItem),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              color: _isSelected
                ? AppColor.lightGrayEAEDF2
                : Colors.transparent,
            ),
            padding: const EdgeInsets.all(8),
            height: 36,
            child: Row(children: [
              SvgPicture.asset(
                menuItem.getIcon(imagePaths),
                width: 20,
                height: 20,
                fit: BoxFit.fill,
                colorFilter: AppColor.primaryLinShare.asFilter(),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(
                menuItem.getName(AppLocalizations.of(context)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _titleStyle,
              )),
            ])
          )),
      ),
    );
  }

  bool get _isSelected => menuItemSelected == menuItem;

  TextStyle get _titleStyle {
    if (_isSelected) {
      return ThemeUtils.textStyleInter600().copyWith(
        fontSize: 15,
        height: 20 / 15,
        letterSpacing: 0.0,
        color: Colors.black,
      );
    } else {
      return ThemeUtils.textStyleBodyBody2(color: Colors.black);
    }
  }
}