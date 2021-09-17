
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef OnBackActionClick = void Function();
typedef OnSendEmailActionClick = void Function();
typedef OnAttachFileActionClick = void Function();

class TopBarComposerWidgetBuilder {
  OnBackActionClick? _onBackActionClick;
  OnSendEmailActionClick? _onSendEmailActionClick;
  OnAttachFileActionClick? _onAttachFileActionClick;

  final ImagePaths _imagePaths;
  final bool _isEnableEmailSendButton;

  TopBarComposerWidgetBuilder(this._imagePaths, this._isEnableEmailSendButton);

  void addBackActionClick(OnBackActionClick onBackActionClick) {
    _onBackActionClick = onBackActionClick;
  }

  void addSendEmailActionClick(OnSendEmailActionClick onSendEmailActionClick) {
    _onSendEmailActionClick = onSendEmailActionClick;
  }

  void addAttachFileActionClick(OnAttachFileActionClick onAttachFileActionClick) {
    _onAttachFileActionClick = onAttachFileActionClick;
  }

  Widget build() {
    return Container(
      key: Key('top_bar_composer_widget'),
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      color: Colors.white,
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children:[_buildBackButton()])),
            _buildListOptionButton(),
          ]
        )
      )
    );
  }

  Widget _buildBackButton() {
    return ButtonBuilder(_imagePaths.icComposerClose)
      .padding(5)
      .size(30)
      .onPressActionClick(() {
        if (_onBackActionClick != null) {
          _onBackActionClick!();
        }})
      .build();
  }

  Widget _buildListOptionButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ButtonBuilder(_imagePaths.icComposerFileShare).key(Key('button_file_share')).build(),
        SizedBox(width: 2),
        ButtonBuilder(_imagePaths.icShare)
          .key(Key('button_attachment'))
          .onPressActionClick(() {
            if (_onAttachFileActionClick != null) {
              _onAttachFileActionClick!();
            }})
          .build(),
        SizedBox(width: 2),
        ButtonBuilder(_imagePaths.icComposerSend)
          .key(Key('button_send_email'))
          .color(_isEnableEmailSendButton ? AppColor.enableSendEmailButtonColor : AppColor.disableSendEmailButtonColor)
          .onPressActionClick(() {
            if (_onSendEmailActionClick != null && _isEnableEmailSendButton) {
              _onSendEmailActionClick!();
            }})
          .build(),
        SizedBox(width: 2),
        ButtonBuilder(_imagePaths.icComposerMenu).key(Key('button_menu_composer')).build(),
      ]
    );
  }
}