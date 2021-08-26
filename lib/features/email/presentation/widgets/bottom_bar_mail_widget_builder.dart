import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnPressEmailActionClick = void Function(EmailActionType emailActionType);

class BottomBarMailWidgetBuilder {

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;

  OnPressEmailActionClick? _onPressEmailActionClick;

  BottomBarMailWidgetBuilder(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
  );

  void addOnPressEmailAction(OnPressEmailActionClick onPressEmailActionClick) {
    _onPressEmailActionClick = onPressEmailActionClick;
  }

  Widget build() {
    return Container(
      key: Key('bottom_bar_messenger_widget'),
      alignment: Alignment.center,
      color: Colors.white,
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: _buildListOptionButton()
      )
    );
  }

  Widget _buildListOptionButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ButtonBuilder(_imagePaths.icReplyAll)
          .key(Key('button_reply_all_message'))
          .onPressActionClick(() {
            if (_onPressEmailActionClick != null) {
              _onPressEmailActionClick!(EmailActionType.replyAll);
            }})
          .text(AppLocalizations.of(_context).reply_all, isVertical: _responsiveUtils.isMobile(_context))
          .build(),
        ButtonBuilder(_imagePaths.icReply)
          .key(Key('button_reply_message'))
          .onPressActionClick(() {
            if (_onPressEmailActionClick != null) {
              _onPressEmailActionClick!(EmailActionType.reply);
            }})
          .text(AppLocalizations.of(_context).reply, isVertical: _responsiveUtils.isMobile(_context))
          .build(),
        ButtonBuilder(_imagePaths.icForward)
          .key(Key('button_forward_message'))
          .onPressActionClick(() {
            if (_onPressEmailActionClick != null) {
              _onPressEmailActionClick!(EmailActionType.forward);
            }})
          .text(AppLocalizations.of(_context).forward, isVertical: _responsiveUtils.isMobile(_context))
          .build()
      ]
    );
  }
}