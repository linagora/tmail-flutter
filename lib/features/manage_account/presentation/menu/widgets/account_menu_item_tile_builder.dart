import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

typedef OnSelectAccountMenuItemAction = void Function(AccountMenuItem);

class AccountMenuItemTileBuilder extends StatelessWidget {

  final AccountMenuItem _menuItem;
  final AccountMenuItem? _menuItemSelected;
  final OnSelectAccountMenuItemAction? onSelectAccountMenuItemAction;

  const AccountMenuItemTileBuilder(
    this._menuItem,
    this._menuItemSelected,
    {
      Key? key,
      this.onSelectAccountMenuItemAction
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: InkWell(
        onTap: () => onSelectAccountMenuItemAction?.call(_menuItem),
        child: Container(
          key: const Key('account_menu_item_tile'),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: _getBackgroundColorItem(context)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(children: [
            Row(children: [
              SvgPicture.asset(
                _menuItem.getIcon(imagePaths),
                width: 20,
                height: 20,
                fit: BoxFit.fill),
              const SizedBox(width: 12),
              Expanded(child: Text(
                _menuItem.getName(context),
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                  color: Colors.black
                )
              ))
            ]),
          ])
        )),
    );
  }

  Color _getBackgroundColorItem(BuildContext context) {
    final responsiveUtils = Get.find<ResponsiveUtils>();

    if (_menuItemSelected == _menuItem) {
      return AppColor.colorBgMailboxSelected;
    } else {
      return responsiveUtils.isWebDesktop(context)
        ? AppColor.colorBgDesktop
        : Colors.white;
    }
  }
}