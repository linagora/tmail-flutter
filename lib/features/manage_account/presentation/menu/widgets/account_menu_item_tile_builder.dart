import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

typedef OnSelectAccountMenuItemAction = void Function(AccountMenuItem);

class AccountMenuItemTileBuilder extends StatelessWidget {

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final AccountMenuItem _menuItem;
  final AccountMenuItem _menuItemSelected;
  final OnSelectAccountMenuItemAction? onSelectAccountMenuItemAction;

  const AccountMenuItemTileBuilder(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
    this._menuItem,
    this._menuItemSelected,
    {Key? key, this.onSelectAccountMenuItemAction}
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelectAccountMenuItemAction?.call(_menuItem),
      child: Theme(
        data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent),
        child: Container(
            key: const Key('account_menu_item_tile'),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: backgroundColorItem),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: MediaQuery(
                data: const MediaQueryData(padding: EdgeInsets.zero),
                child: Column(children: [
                  Row(children: [
                    SvgPicture.asset(_menuItem.getIcon(_imagePaths), width: 28, height: 28, fit: BoxFit.fill),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_menuItem.getName(context),
                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.black)))
                  ]),
                ])
            )
        )
    ));
  }

  Color get backgroundColorItem {
    if (_menuItemSelected == _menuItem) {
      return AppColor.colorBgMailboxSelected;
    }
    return _responsiveUtils.isDesktop(_context) ? AppColor.colorBgDesktop : Colors.white;
  }
}