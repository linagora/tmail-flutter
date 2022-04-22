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
  final PresentationMailbox? _currentMailbox;

  OnPressEmailSelectionActionClick? _onPressEmailSelectionActionClick;

  BottomBarThreadSelectionWidget(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
    this._listSelectionEmail,
    this._currentMailbox,
  );

  void addOnPressEmailSelectionActionClick(OnPressEmailSelectionActionClick onPressEmailSelectionActionClick) {
    _onPressEmailSelectionActionClick = onPressEmailSelectionActionClick;
  }

  Widget build() {
    return Container(
      key: const Key('bottom_bar_thread_selection_widget'),
      alignment: Alignment.center,
      color: Colors.white,
      child: MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.zero),
        child: _buildListOptionButton()
      )
    );
  }

  Widget _buildListOptionButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: (ButtonBuilder(_listSelectionEmail.isAllEmailRead ? _imagePaths.icUnread : _imagePaths.icRead)
            ..key(const Key('button_mark_read_email'))
            ..paddingIcon(const EdgeInsets.all(8))
            ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButton))
            ..onPressActionClick(() {
              if (_onPressEmailSelectionActionClick != null) {
                _onPressEmailSelectionActionClick!(
                    _listSelectionEmail.isAllEmailRead ? EmailActionType.markAsUnread : EmailActionType.markAsRead,
                    _listSelectionEmail);
              }})
            ..text(
                _listSelectionEmail.isAllEmailRead ? AppLocalizations.of(_context).unread : AppLocalizations.of(_context).read,
                isVertical: _responsiveUtils.isMobile(_context)))
          .build()),
        Expanded(child: (ButtonBuilder(_listSelectionEmail.isAllEmailStarred ? _imagePaths.icUnStar : _imagePaths.icStar)
            ..key(const Key('button_mark_as_star_email'))
            ..paddingIcon(const EdgeInsets.all(8))
            ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButton))
            ..onPressActionClick(() {
              if (_onPressEmailSelectionActionClick != null) {
                _onPressEmailSelectionActionClick!(
                    _listSelectionEmail.isAllEmailStarred ? EmailActionType.unMarkAsStarred : EmailActionType.markAsStarred,
                    _listSelectionEmail);
              }})
            ..text(_listSelectionEmail.isAllEmailStarred ? AppLocalizations.of(_context).un_star : AppLocalizations.of(_context).star,
                isVertical: _responsiveUtils.isMobile(_context)))
          .build()),
        if (_currentMailbox?.isDrafts == false)
          Expanded(child: (ButtonBuilder(_imagePaths.icMove)
              ..key(const Key('button_move_to_mailbox'))
              ..paddingIcon(const EdgeInsets.all(8))
              ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButton))
              ..onPressActionClick(() {
                if (_onPressEmailSelectionActionClick != null) {
                  _onPressEmailSelectionActionClick!(EmailActionType.moveToMailbox, _listSelectionEmail);
                }})
              ..text(AppLocalizations.of(_context).move, isVertical: _responsiveUtils.isMobile(_context)))
            .build()),
        if (_currentMailbox?.isDrafts == false)
          Expanded(child: (ButtonBuilder(_currentMailbox?.isSpam == true ? _imagePaths.icNotSpam : _imagePaths.icSpam)
              ..key(const Key('button_move_to_spam'))
              ..paddingIcon(const EdgeInsets.all(8))
              ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButton))
              ..onPressActionClick(() {
                if (_currentMailbox?.isSpam == true) {
                  _onPressEmailSelectionActionClick?.call(EmailActionType.unSpam, _listSelectionEmail);
                } else {
                  _onPressEmailSelectionActionClick?.call(EmailActionType.moveToSpam, _listSelectionEmail);
                }
              })
              ..text(_currentMailbox?.isSpam == true
                    ? AppLocalizations.of(_context).un_spam
                    : AppLocalizations.of(_context).spam,
                  isVertical: _responsiveUtils.isMobile(_context)))
            .build()),
        Expanded(child: (ButtonBuilder(_imagePaths.icDelete)
            ..key(const Key('button_delete_email'))
            ..paddingIcon(const EdgeInsets.all(8))
            ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButton))
            ..onPressActionClick(() {
              if (_currentMailbox?.isTrash == true) {
                _onPressEmailSelectionActionClick?.call(EmailActionType.deletePermanently, _listSelectionEmail);
              } else {
                _onPressEmailSelectionActionClick?.call(EmailActionType.moveToTrash, _listSelectionEmail);
              }
            })
            ..text(AppLocalizations.of(_context).delete, isVertical: _responsiveUtils.isMobile(_context)))
          .build())
      ]
    );
  }
}