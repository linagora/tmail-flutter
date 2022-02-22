
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnCancelActionClick = void Function();
typedef OnCreateActionClick = void Function();

class AppBarMailboxCreatorWidget {
  OnCancelActionClick? _cancelActionClick;
  OnCreateActionClick? _createActionClick;

  final BuildContext _context;
  final bool isValidated;

  AppBarMailboxCreatorWidget(
      this._context,
      {this.isValidated = false}
  );

  void addOnCancelActionClick(OnCancelActionClick onCancelActionClick) {
    _cancelActionClick = onCancelActionClick;
  }

  void addOnCreateActionClick(OnCreateActionClick onCreateActionClick) {
    _createActionClick = onCreateActionClick;
  }

  Widget build() {
    return Container(
        key: Key('app_bar_mailbox_creator'),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: AppColor.colorBgMailbox),
        child: MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.zero),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCancelButton(),
                  Expanded(child: _buildTitle()),
                  _buildCreateButton()
                ]
            )
        )
    );
  }

  Widget _buildCancelButton() {
    return Material(
        borderRadius: BorderRadius.circular(20),
        color: Colors.transparent,
        child: TextButton(
            child: Text(
              AppLocalizations.of(_context).cancel,
              style: TextStyle(fontSize: 17, color: AppColor.colorTextButton),
            ),
            onPressed: () => _cancelActionClick?.call()
        )
    );
  }

  Widget _buildCreateButton() {
    return Material(
        borderRadius: BorderRadius.circular(20),
        color: Colors.transparent,
        child: TextButton(
            child: Text(
              AppLocalizations.of(_context).done,
              style: TextStyle(fontSize: 17, color: isValidated ? AppColor.colorTextButton : AppColor.colorDisableMailboxCreateButton),
            ),
            onPressed: () => _createActionClick?.call()
        )
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        AppLocalizations.of(_context).new_mailbox,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 17, color: AppColor.colorNameEmail, fontWeight: FontWeight.w700)));
  }
}