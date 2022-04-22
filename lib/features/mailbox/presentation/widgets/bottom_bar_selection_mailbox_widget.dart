import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnMailboxActionsClick = void Function(MailboxActions, List<PresentationMailbox>);

class BottomBarSelectionMailboxWidget {

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final List<PresentationMailbox> _listSelectionMailbox;

  OnMailboxActionsClick? _onMailboxActionsClick;

  BottomBarSelectionMailboxWidget(
    this._context,
    this._imagePaths,
    this._listSelectionMailbox,
  );

  void addOnMailboxActionsClick(OnMailboxActionsClick onMailboxActionsClick) {
    _onMailboxActionsClick = onMailboxActionsClick;
  }

  Widget build() {
    return Container(
      key: const Key('bottom_bar_selection_mailbox_widget'),
      alignment: Alignment.center,
      color: Colors.white,
      child: MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.zero),
        child: SafeArea(child: _buildListOptionButton())
      )
    );
  }

  Widget _buildListOptionButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: (ButtonBuilder(_imagePaths.icMove)
            ..key(const Key('button_move_all_mailbox'))
            ..paddingIcon(const EdgeInsets.all(8))
            ..textStyle(TextStyle(fontSize: 12, color: AppColor.colorTextButton.withOpacity(0.3)))
            ..iconColor(AppColor.colorTextButton.withOpacity(0.3))
            ..onPressActionClick(() => {})
            ..text(AppLocalizations.of(_context).move, isVertical: true))
          .build()),
        Expanded(child: (ButtonBuilder(_imagePaths.icRenameMailbox)
            ..key(const Key('button_rename_mailbox'))
            ..paddingIcon(const EdgeInsets.all(8))
            ..textStyle(TextStyle(
                fontSize: 12,
                color: _isRenameMailboxValid ? AppColor.colorTextButton : AppColor.colorTextButton.withOpacity(0.3)))
            ..iconColor(_isRenameMailboxValid ? AppColor.colorTextButton : AppColor.colorTextButton.withOpacity(0.3))
            ..onPressActionClick(() {
              if (_isRenameMailboxValid) {
                _onMailboxActionsClick?.call(MailboxActions.rename, _listSelectionMailbox);
              }
            })
            ..text(AppLocalizations.of(_context).rename, isVertical: true))
          .build()),
        Expanded(child: (ButtonBuilder(_imagePaths.icRead)
            ..key(const Key('button_mark_read_all_mailbox'))
            ..paddingIcon(const EdgeInsets.all(8))
            ..textStyle(TextStyle(fontSize: 12, color: AppColor.colorTextButton.withOpacity(0.3)))
            ..iconColor(AppColor.colorTextButton.withOpacity(0.3))
            ..onPressActionClick(() => {})
            ..text(AppLocalizations.of(_context).mark_as_read, isVertical: true))
          .build()),
        Expanded(child: (ButtonBuilder(_imagePaths.icDelete)
            ..key(const Key('button_delete_all_mailbox'))
            ..paddingIcon(const EdgeInsets.all(8))
            ..textStyle(TextStyle(
                fontSize: 12,
                color: _isDeleteMailboxValid ? AppColor.colorTextButton : AppColor.colorTextButton.withOpacity(0.3)))
            ..iconColor(_isDeleteMailboxValid ? AppColor.colorTextButton : AppColor.colorTextButton.withOpacity(0.3))
            ..onPressActionClick(() {
              if (_isDeleteMailboxValid) {
                _onMailboxActionsClick?.call(MailboxActions.delete, _listSelectionMailbox);
              }
            })
            ..text(AppLocalizations.of(_context).delete, isVertical: true))
          .build())
      ]
    );
  }

  bool get _isDeleteMailboxValid => _listSelectionMailbox.length == 1 && _isAllFolderMailbox;

  bool get _isRenameMailboxValid => _listSelectionMailbox.length == 1 && _isAllFolderMailbox;

  bool get _isAllFolderMailbox => _listSelectionMailbox.every((mailbox) => !mailbox.hasRole());
}