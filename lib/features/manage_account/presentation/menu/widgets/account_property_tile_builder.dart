import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_property.dart';

class AccountPropertyTileBuilder extends StatelessWidget {

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final AccountProperty _accountProperty;
  final AccountProperty _accountPropertySelected;

  const AccountPropertyTileBuilder(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
    this._accountProperty,
    this._accountPropertySelected, {Key? key}
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent),
        child: Container(
            key: const Key('account_property_tile'),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: backgroundColorItem
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: MediaQuery(
                data: const MediaQueryData(padding: EdgeInsets.zero),
                child: Column(children: [
                  Row(children: [
                    SvgPicture.asset(_accountProperty.getIcon(_imagePaths), width: 28, height: 28, fit: BoxFit.fill),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_accountProperty.getName(context),
                      style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.black)))
                  ]),
                ])
            )
        )
    );
  }

  Color get backgroundColorItem {
    if (_accountPropertySelected == _accountProperty) {
      return AppColor.colorBgMailboxSelected;
    }
    return _responsiveUtils.isDesktop(_context) ? AppColor.colorBgDesktop : Colors.white;
  }
}