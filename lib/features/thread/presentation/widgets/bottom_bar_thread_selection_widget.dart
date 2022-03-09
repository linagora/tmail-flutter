import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnPressEmailSelectionActionClick = void Function(EmailActionType, List<PresentationEmail>);

class BottomBarThreadSelectionWidget {

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final List<PresentationEmail> _listSelectionEmail;

  OnPressEmailSelectionActionClick? _onPressEmailSelectionActionClick;

  BottomBarThreadSelectionWidget(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
    this._listSelectionEmail,
  );

  void addOnPressEmailSelectionActionClick(OnPressEmailSelectionActionClick onPressEmailSelectionActionClick) {
    _onPressEmailSelectionActionClick = onPressEmailSelectionActionClick;
  }

  Widget build() {
    return Container(
      key: Key('bottom_bar_thread_selection_widget'),
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
        (ButtonBuilder(_listSelectionEmail.isAllEmailRead ? _imagePaths.icUnread : _imagePaths.icRead)
            ..key(Key('button_mark_read_email'))
            ..paddingIcon(EdgeInsets.all(8))
            ..textStyle(TextStyle(fontSize: 12, color: AppColor.colorTextButton))
            ..onPressActionClick(() {
              if (_onPressEmailSelectionActionClick != null) {
                _onPressEmailSelectionActionClick!(
                    _listSelectionEmail.isAllEmailRead ? EmailActionType.markAsUnread : EmailActionType.markAsRead,
                    _listSelectionEmail);
              }})
            ..text(
                _listSelectionEmail.isAllEmailRead ? AppLocalizations.of(_context).unread : AppLocalizations.of(_context).read,
                isVertical: _responsiveUtils.isMobile(_context)))
          .build(),
        (ButtonBuilder(_imagePaths.icFlag)
            ..key(Key('button_flag_email'))
            ..paddingIcon(EdgeInsets.all(8))
            ..textStyle(TextStyle(fontSize: 12, color: AppColor.colorTextButton))
            ..onPressActionClick(() {
              if (_onPressEmailSelectionActionClick != null) {
                _onPressEmailSelectionActionClick!(EmailActionType.markAsFlag, _listSelectionEmail);
              }})
            ..text(AppLocalizations.of(_context).flag, isVertical: _responsiveUtils.isMobile(_context)))
          .build(),
        (ButtonBuilder(_imagePaths.icMove)
            ..key(Key('button_move_email'))
            ..paddingIcon(EdgeInsets.all(8))
            ..textStyle(TextStyle(fontSize: 12, color: AppColor.colorTextButton))
            ..onPressActionClick(() {
              if (_onPressEmailSelectionActionClick != null) {
                _onPressEmailSelectionActionClick!(EmailActionType.move, _listSelectionEmail);
              }})
            ..text(AppLocalizations.of(_context).move, isVertical: _responsiveUtils.isMobile(_context)))
          .build(),
        if (!_responsiveUtils.isDesktop(_context) && !_responsiveUtils.isTabletLarge(_context))
          (ButtonBuilder(_imagePaths.icSpam)
            ..key(Key('button_spam_email'))
            ..paddingIcon(EdgeInsets.all(8))
            ..textStyle(TextStyle(fontSize: 12, color: AppColor.colorTextButton))
            ..onPressActionClick(() {
              if (_onPressEmailSelectionActionClick != null) {
                _onPressEmailSelectionActionClick!(EmailActionType.markAsSpam, _listSelectionEmail);
              }})
            ..text(AppLocalizations.of(_context).spam, isVertical: _responsiveUtils.isMobile(_context)))
          .build(),
        if (!_responsiveUtils.isDesktop(_context) && !_responsiveUtils.isTabletLarge(_context))
          (ButtonBuilder(_imagePaths.icDelete)
            ..key(Key('button_delete_email'))
            ..paddingIcon(EdgeInsets.all(8))
            ..textStyle(TextStyle(fontSize: 12, color: AppColor.colorTextButton))
            ..onPressActionClick(() {
              if (_onPressEmailSelectionActionClick != null) {
                _onPressEmailSelectionActionClick!(EmailActionType.delete, _listSelectionEmail);
              }})
            ..text(AppLocalizations.of(_context).delete, isVertical: _responsiveUtils.isMobile(_context)))
          .build()
      ]
    );
  }
}