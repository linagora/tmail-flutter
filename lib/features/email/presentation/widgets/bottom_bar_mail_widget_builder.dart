import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnPressEmailActionClick = void Function(EmailActionType emailActionType);

class BottomBarMailWidgetBuilder {

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final PresentationEmail? _presentationEmail;

  OnPressEmailActionClick? _onPressEmailActionClick;

  BottomBarMailWidgetBuilder(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
    this._presentationEmail,
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
        child: _presentationEmail != null ? _buildListOptionButton(_presentationEmail!) : SizedBox.shrink()
      )
    );
  }

  Widget _buildListOptionButton(PresentationEmail presentationEmail) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (presentationEmail.numberOfAllEmailAddress() > 1)
          (ButtonBuilder(_imagePaths.icReplyAll)
            ..key(Key('button_reply_all_message'))
            ..size(15)
            ..paddingIcon(EdgeInsets.only(
                top: _responsiveUtils.isMobileDevice(_context) ? 10 : 16,
                bottom: _responsiveUtils.isMobileDevice(_context) ? 8 : 16,
                right: 5))
            ..textStyle(TextStyle(
                fontSize: _responsiveUtils.isMobileDevice(_context) ? 12 : 16,
                color: AppColor.colorTextButton))
            ..onPressActionClick(() {
              if (_onPressEmailActionClick != null) {
                _onPressEmailActionClick!(EmailActionType.replyAll);
              }})
            ..text(AppLocalizations.of(_context).reply_all, isVertical: _responsiveUtils.isMobile(_context)))
          .build(),
        (ButtonBuilder(_imagePaths.icReply)
            ..key(Key('button_reply_message'))
            ..size(20)
            ..paddingIcon(EdgeInsets.only(
                top: _responsiveUtils.isMobileDevice(_context) ? 10 : 16,
                bottom: _responsiveUtils.isMobileDevice(_context) ? 8 : 16,
                right: 5))
            ..textStyle(TextStyle(
                fontSize: _responsiveUtils.isMobileDevice(_context) ? 12 : 16,
                color: AppColor.colorTextButton))
            ..onPressActionClick(() {
              if (_onPressEmailActionClick != null) {
                _onPressEmailActionClick!(EmailActionType.reply);
              }})
            ..text(AppLocalizations.of(_context).reply, isVertical: _responsiveUtils.isMobile(_context)))
          .build(),
        (ButtonBuilder(_imagePaths.icForward)
            ..key(Key('button_forward_message'))
            ..size(20)
            ..paddingIcon(EdgeInsets.only(
                top: _responsiveUtils.isMobileDevice(_context) ? 10 : 16,
                bottom: _responsiveUtils.isMobileDevice(_context) ? 8 : 16,
                right: 5))
            ..textStyle(TextStyle(
                fontSize: _responsiveUtils.isMobileDevice(_context) ? 12 : 16,
                color: AppColor.colorTextButton))
            ..onPressActionClick(() {
              if (_onPressEmailActionClick != null) {
                _onPressEmailActionClick!(EmailActionType.forward);
              }})
            ..text(AppLocalizations.of(_context).forward, isVertical: _responsiveUtils.isMobile(_context)))
          .build(),
        if (!_responsiveUtils.isDesktop(_context))
          (ButtonBuilder(_imagePaths.icNewMessage)
              ..key(Key('button_new_message'))
              ..size(20)
              ..paddingIcon(EdgeInsets.only(
                  top: _responsiveUtils.isMobileDevice(_context) ? 10 : 16,
                  bottom: _responsiveUtils.isMobileDevice(_context) ? 8 : 16,
                  right: 5))
              ..textStyle(TextStyle(
                  fontSize: _responsiveUtils.isMobileDevice(_context) ? 12 : 16,
                  color: AppColor.colorTextButton))
              ..onPressActionClick(() {
                if (_onPressEmailActionClick != null) {
                  _onPressEmailActionClick!(EmailActionType.compose);
                }})
              ..text(AppLocalizations.of(_context).new_message, isVertical: _responsiveUtils.isMobile(_context)))
            .build()
      ]
    );
  }
}