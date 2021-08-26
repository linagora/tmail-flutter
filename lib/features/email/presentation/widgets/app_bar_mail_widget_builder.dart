
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

typedef OnBackActionClick = void Function();

class AppBarMailWidgetBuilder {
  OnBackActionClick? _onBackActionClick;

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

  AppBarMailWidgetBuilder onBackActionClick(
      OnBackActionClick onBackActionClick) {
    _onBackActionClick = onBackActionClick;
    return this;
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
        ButtonBuilder(_imagePaths.icTrash).key(Key('button_delete_message')).build(),
        SizedBox(width: 10),
        ButtonBuilder(_imagePaths.icEyeDisable).key(Key('button_hide_message')).build(),
        SizedBox(width: 10),
        ButtonBuilder((_presentationEmail != null && _presentationEmail!.isFlaggedEmail())
            ? _imagePaths.icFlagged
            : _imagePaths.icFlag)
          .key(Key('button_favorite_message'))
          .build(),
        SizedBox(width: 10),
        ButtonBuilder(_imagePaths.icFolder).key(Key('button_add_folder_message')).build(),
      ]
    );
  }
}