
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_action.dart';

typedef OnCloseActionClick = void Function();

class AppBarDestinationPickerBuilder {
  OnCloseActionClick? _onCloseActionClick;

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final MailboxAction? _mailboxAction;

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
                crossAxisAlignment: CrossAxisAlignment.center,
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
    return Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: _responsiveUtils.isMobile(_context)
          ? IconButton(
              color: _mailboxAction == MailboxAction.create ? AppColor.colorTextButton : AppColor.baseTextColor,
              icon: _getBackIcon(),
              onPressed: () => _onCloseActionClick?.call())
          : SizedBox(width: 40, height: 40)
    );
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
    if (_mailboxAction == MailboxAction.create) {
      return TextAlign.center;
    } else {
      return _responsiveUtils.isMobile(_context) ? TextAlign.start : TextAlign.center;
    }
  }

  Widget _getBackIcon() {
    if (_mailboxAction == MailboxAction.create) {
      return SvgPicture.asset(_imagePaths.icBack, fit: BoxFit.fill);
    } else {
      return SvgPicture.asset(_imagePaths.icComposerClose, fit: BoxFit.fill);
    }
  }
}