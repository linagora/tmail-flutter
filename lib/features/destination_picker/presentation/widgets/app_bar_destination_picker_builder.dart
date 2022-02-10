
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnCloseActionClick = void Function();

class AppBarDestinationPickerBuilder {
  OnCloseActionClick? _onCloseActionClick;

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;

  AppBarDestinationPickerBuilder(this._context, this._imagePaths, this._responsiveUtils);

  void addCloseActionClick(OnCloseActionClick onCloseActionClick) {
    _onCloseActionClick = onCloseActionClick;
  }

  Widget build() {
    return Container(
        key: Key('app_bar_destination_picker'),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        color: Colors.white,
        child: MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.zero),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildBackButton(),
                  Expanded(child: _buildCountItemSelected())
                ]
            )
        )
    );
  }

  Widget _buildBackButton() {
    return Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: IconButton(
            color: AppColor.baseTextColor,
            icon: SvgPicture.asset(_imagePaths.icComposerClose, fit: BoxFit.fill),
            onPressed: () => _onCloseActionClick?.call()
        )
    );
  }

  Widget _buildCountItemSelected() {
    return Padding(
      padding: EdgeInsets.only(
          left: 12,
          right: _responsiveUtils.isMobile(_context) ? 0 : 47),
      child: Text(
        AppLocalizations.of(_context).move_to_mailbox,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: _responsiveUtils.isMobile(_context) ? TextAlign.start : TextAlign.center,
        style: TextStyle(fontSize: 18, color: AppColor.nameUserColor, fontWeight: FontWeight.w500)));
  }
}