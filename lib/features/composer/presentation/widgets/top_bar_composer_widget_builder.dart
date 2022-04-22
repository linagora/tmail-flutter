
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnBackActionClick = void Function();
typedef OnSendEmailActionClick = void Function();
typedef OnAttachFileActionClick = void Function(RelativeRect? position);

class TopBarComposerWidgetBuilder {
  OnBackActionClick? _onBackActionClick;
  OnSendEmailActionClick? _onSendEmailActionClick;
  OnAttachFileActionClick? _onAttachFileActionClick;

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final bool _isEnableEmailSendButton;

  TopBarComposerWidgetBuilder(
      this._context,
      this._imagePaths,
      this._isEnableEmailSendButton,
  );

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
      key: const Key('top_bar_composer_widget'),
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      child: MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.zero),
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
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child:  GestureDetector(
            onTap: () {
              if (!kIsWeb) {
                _onAttachFileActionClick?.call(null);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: kIsWeb ? 16 : 0),
              child: SvgPicture.asset(_imagePaths.icShare, fit: BoxFit.fill),
            ),
            onTapDown: (detail) {
              if (kIsWeb) {
                final screenSize = MediaQuery.of(_context).size;
                final offset = detail.globalPosition;
                final position = RelativeRect.fromLTRB(
                  offset.dx,
                  offset.dy,
                  screenSize.width - offset.dx,
                  screenSize.height - offset.dy,
                );
                _onAttachFileActionClick?.call(position);
              }
            },
          ),
        ),
        IconButton(
            key: const Key('button_send_email'),
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
        const SizedBox(width: 8)
      ]
    );
  }
}