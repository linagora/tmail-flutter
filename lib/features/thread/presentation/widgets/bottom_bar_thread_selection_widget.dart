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
            ..paddingIcon(const EdgeInsets.symmetric(horizontal: 8, vertical: 4))
            ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButton))
            ..onPressActionClick(() {
              if (_onPressEmailSelectionActionClick != null) {
                _onPressEmailSelectionActionClick!(
                    _listSelectionEmail.isAllEmailRead ? EmailActionType.markAsUnread : EmailActionType.markAsRead,
                    _listSelectionEmail);
              }})
            ..text(_textButtonMarkAsRead, isVertical: _responsiveUtils.isMobile(_context)))
          .build()),
        Expanded(child: (ButtonBuilder(_listSelectionEmail.isAllEmailStarred ? _imagePaths.icUnStar : _imagePaths.icStar)
            ..key(const Key('button_mark_as_star_email'))
            ..paddingIcon(const EdgeInsets.symmetric(horizontal: 8, vertical: 4))
            ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButton))
            ..onPressActionClick(() {
              if (_onPressEmailSelectionActionClick != null) {
                _onPressEmailSelectionActionClick!(
                    _listSelectionEmail.isAllEmailStarred ? EmailActionType.unMarkAsStarred : EmailActionType.markAsStarred,
                    _listSelectionEmail);
              }})
            ..text(_textButtonMarkAsStar, isVertical: _responsiveUtils.isMobile(_context)))
          .build()),
        if (_currentMailbox?.isDrafts == false)
          Expanded(child: (ButtonBuilder(_imagePaths.icMove)
              ..key(const Key('button_move_to_mailbox'))
              ..paddingIcon(const EdgeInsets.symmetric(horizontal: 8, vertical: 4))
              ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButton))
              ..onPressActionClick(() {
                if (_onPressEmailSelectionActionClick != null) {
                  _onPressEmailSelectionActionClick!(EmailActionType.moveToMailbox, _listSelectionEmail);
                }})
              ..text(_textButtonMove, isVertical: _responsiveUtils.isMobile(_context)))
            .build()),
        if (_currentMailbox?.isDrafts == false)
          Expanded(child: (ButtonBuilder(_currentMailbox?.isSpam == true ? _imagePaths.icNotSpam : _imagePaths.icSpam)
              ..key(const Key('button_move_to_spam'))
              ..paddingIcon(const EdgeInsets.symmetric(horizontal: 8, vertical: 4))
              ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButton))
              ..onPressActionClick(() {
                if (_currentMailbox?.isSpam == true) {
                  _onPressEmailSelectionActionClick?.call(EmailActionType.unSpam, _listSelectionEmail);
                } else {
                  _onPressEmailSelectionActionClick?.call(EmailActionType.moveToSpam, _listSelectionEmail);
                }
              })
              ..text(_textButtonSpam, isVertical: _responsiveUtils.isMobile(_context)))
            .build()),
        Expanded(child: (ButtonBuilder(canDeletePermanently ? _imagePaths.icDeleteComposer : _imagePaths.icDelete)
            ..key(const Key('button_delete_email'))
            ..iconColor(canDeletePermanently ? AppColor.colorDeletePermanentlyButton : AppColor.primaryColor)
            ..paddingIcon(const EdgeInsets.symmetric(horizontal: 8, vertical: 4))
            ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButton))
            ..onPressActionClick(() {
              if (canDeletePermanently) {
                _onPressEmailSelectionActionClick?.call(EmailActionType.deletePermanently, _listSelectionEmail);
              } else {
                _onPressEmailSelectionActionClick?.call(EmailActionType.moveToTrash, _listSelectionEmail);
              }
            })
            ..text(_textButtonDelete, isVertical: _responsiveUtils.isMobile(_context)))
          .build())
      ]
    );
  }

  bool get canDeletePermanently {
    return _currentMailbox?.isTrash == true || _currentMailbox?.isDrafts == true;
  }

  String? get _textButtonMarkAsRead {
    if (!_isMailboxDashboardSplitView(_context)) {
      return _listSelectionEmail.isAllEmailRead
          ? AppLocalizations.of(_context).unread
          : AppLocalizations.of(_context).read;
    }
    return null;
  }

  String? get _textButtonMarkAsStar {
    if (!_isMailboxDashboardSplitView(_context)) {
      return _listSelectionEmail.isAllEmailStarred
          ? AppLocalizations.of(_context).un_star
          : AppLocalizations.of(_context).star;
    }
    return null;
  }

  String? get _textButtonMove {
    if (!_isMailboxDashboardSplitView(_context)) {
      return AppLocalizations.of(_context).move;
    }
    return null;
  }

  String? get _textButtonSpam {
    if (!_isMailboxDashboardSplitView(_context)) {
      return _currentMailbox?.isSpam == true
          ? AppLocalizations.of(_context).un_spam
          : AppLocalizations.of(_context).spam;
    }
    return null;
  }

  String? get _textButtonDelete {
    if (!_isMailboxDashboardSplitView(_context)) {
      return AppLocalizations.of(_context).delete;
    }
    return null;
  }

  bool _isMailboxDashboardSplitView(BuildContext context) {
    if (BuildUtils.isWeb) {
      return _responsiveUtils.isTabletLarge(context);
    } else {
      return _responsiveUtils.isLandscapeTablet(context) ||
          _responsiveUtils.isTabletLarge(context) ||
          _responsiveUtils.isDesktop(context);
    }
  }
}