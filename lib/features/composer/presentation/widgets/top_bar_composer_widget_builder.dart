
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    return IconButton(
      color: AppColor.baseTextColor,
      icon: SvgPicture.asset(_imagePaths.icComposerClose, color: AppColor.baseTextColor, fit: BoxFit.fill),
      onPressed: () {
        if (_onBackActionClick != null) {
          _onBackActionClick!();
        }
      }
    );
  }

  Widget _buildListOptionButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // IconButton(
        //   key: Key('button_file_share'),
        //   color: AppColor.baseTextColor,
        //   icon: SvgPicture.asset(_imagePaths.icComposerFileShare, color: AppColor.baseTextColor, fit: BoxFit.fill),
        //   onPressed: () {}
        // ),
        IconButton(
            key: Key('button_attachment'),
            color: AppColor.baseTextColor,
            icon: SvgPicture.asset(_imagePaths.icShare, color: AppColor.baseTextColor, fit: BoxFit.fill),
            onPressed: () {
              if (_onAttachFileActionClick != null) {
                _onAttachFileActionClick!();
              }
            }
        ),
        IconButton(
            key: Key('button_send_email'),
            color: _isEnableEmailSendButton ? AppColor.enableSendEmailButtonColor : AppColor.disableSendEmailButtonColor,
            icon: SvgPicture.asset(
                _imagePaths.icComposerSend,
                color: _isEnableEmailSendButton ? AppColor.enableSendEmailButtonColor : AppColor.disableSendEmailButtonColor,
                fit: BoxFit.fill),
            onPressed: () {
              if (_onSendEmailActionClick != null) {
                _onSendEmailActionClick!();
              }
            }
        ),
        SizedBox(width: 8)
        // IconButton(
        //   key: Key('button_menu_composer'),
        //   color: AppColor.baseTextColor,
        //   icon: SvgPicture.asset(_imagePaths.icComposerMenu, color: AppColor.baseTextColor, fit: BoxFit.fill),
        //   onPressed: () {}
        // )
      ]
    );
  }
}