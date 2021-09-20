
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

typedef OnBackActionClick = void Function();
typedef OnUnreadEmailActionClick = void Function(PresentationEmail presentationEmail);
typedef OnMoveToMailboxActionClick = void Function(PresentationEmail presentationEmail);

class AppBarMailWidgetBuilder {
  OnBackActionClick? _onBackActionClick;
  OnUnreadEmailActionClick? _onUnreadEmailActionClick;
  OnMoveToMailboxActionClick? _onMoveToMailboxActionClick;

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final PresentationEmail? _presentationEmail;

  AppBarMailWidgetBuilder(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
    this._presentationEmail,
  );

  void onBackActionClick(OnBackActionClick onBackActionClick) {
    _onBackActionClick = onBackActionClick;
  }

  void onUnreadEmailActionClick(OnUnreadEmailActionClick onUnreadEmailActionClick) {
    _onUnreadEmailActionClick = onUnreadEmailActionClick;
  }

  void addOnMoveToMailboxActionClick(OnMoveToMailboxActionClick onMoveToMailboxActionClick) {
    _onMoveToMailboxActionClick = onMoveToMailboxActionClick;
  }

  Widget build() {
    return Container(
      key: Key('app_bar_messenger_widget'),
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      color: Colors.white,
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!_responsiveUtils.isDesktop(_context) || Get.currentRoute != AppRoutes.MAILBOX_DASHBOARD)
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
    return ButtonBuilder(_imagePaths.icBack)
      .size(20)
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
        ButtonBuilder(_imagePaths.icTrash).key(Key('button_move_to_trash_email')).build(),
        SizedBox(width: 10),
        ButtonBuilder(_imagePaths.icEyeDisable)
          .key(Key('button_mark_as_unread_email'))
          .onPressActionClick(() {
            if (_onUnreadEmailActionClick != null && _presentationEmail != null && _presentationEmail!.isReadEmail()) {
              _onUnreadEmailActionClick!(_presentationEmail!);
            }})
          .build(),
        SizedBox(width: 10),
        ButtonBuilder((_presentationEmail != null && _presentationEmail!.isFlaggedEmail())
            ? _imagePaths.icFlagged
            : _imagePaths.icFlag)
          .key(Key('button_mark_as_flag_email'))
          .build(),
        SizedBox(width: 10),
        ButtonBuilder(_imagePaths.icFolder)
          .key(Key('button_move_to_mailbox_email'))
          .onPressActionClick(() {
            if (_onMoveToMailboxActionClick != null && _presentationEmail != null) {
              _onMoveToMailboxActionClick!(_presentationEmail!);
            }})
          .build(),
      ]
    );
  }
}