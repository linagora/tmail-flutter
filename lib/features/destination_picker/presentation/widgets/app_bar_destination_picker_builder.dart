
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';

typedef OnCloseActionClick = void Function();

class AppBarDestinationPickerBuilder {
  OnCloseActionClick? _onCloseActionClick;

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final MailboxActions? _mailboxAction;

  AppBarDestinationPickerBuilder(
      this._context,
      this._imagePaths,
      this._responsiveUtils,
      this._mailboxAction,
  );

  void addCloseActionClick(OnCloseActionClick onCloseActionClick) {
    _onCloseActionClick = onCloseActionClick;
  }

  Widget build() {
    return Container(
        key: Key('app_bar_destination_picker'),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: Colors.white),
        child: MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.zero),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildBackButton(),
                  Expanded(child: _buildTitle())
                ]
            )
        )
    );
  }

  Widget _buildBackButton() {
    if (_mailboxAction == MailboxActions.create) {
      if (_responsiveUtils.isMobile(_context)) {
        return Material(
            color: Colors.transparent,
            shape: CircleBorder(),
            child: IconButton(
                splashRadius: 20,
                icon: SvgPicture.asset(_imagePaths.icBack, color: AppColor.colorTextButton, fit: BoxFit.fill),
                onPressed: () => _onCloseActionClick?.call()));
      } else {
        return SizedBox(width: 40, height: 40);
      }
    } else {
      return Material(
          color: Colors.transparent,
          shape: CircleBorder(),
          child: IconButton(
              splashRadius: 20,
              icon: SvgPicture.asset(_imagePaths.icComposerClose, color: AppColor.baseTextColor, fit: BoxFit.fill),
              onPressed: () => _onCloseActionClick?.call()));
    }
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.only(
          left: 12,
          right: 47),
      child: Text(
        _mailboxAction?.getTitle(_context) ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: _getAlignTitle(),
        style: TextStyle(fontSize: 17, color: AppColor.colorNameEmail, fontWeight: FontWeight.w700)));
  }

  TextAlign _getAlignTitle() {
    if (_mailboxAction == MailboxActions.create) {
      return TextAlign.center;
    } else {
      return _responsiveUtils.isMobile(_context) ? TextAlign.start : TextAlign.center;
    }
  }
}