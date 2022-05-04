
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnCancelActionClick = void Function();
typedef OnDoneActionClick = void Function();

class AppBarMailboxCreatorBuilder {
  OnCancelActionClick? _cancelActionClick;
  OnDoneActionClick? _onDoneActionClick;

  final BuildContext _context;
  final bool isValidated;
  final String? title;

  AppBarMailboxCreatorBuilder(
      this._context,
      {
        this.title,
        this.isValidated = false
      }
  );

  void addOnCancelActionClick(OnCancelActionClick onCancelActionClick) {
    _cancelActionClick = onCancelActionClick;
  }

  void addOnDoneActionClick(OnDoneActionClick onDoneActionClick) {
    _onDoneActionClick = onDoneActionClick;
  }

  Widget build() {
    return Container(
        key: const Key('app_bar_mailbox_creator'),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: AppColor.colorBgMailbox),
        child: MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.zero),
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
              style: const TextStyle(fontSize: 17, color: AppColor.colorTextButton),
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
            onPressed: () => isValidated ? _onDoneActionClick?.call() : null
        )
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title ?? '',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, color: AppColor.colorNameEmail, fontWeight: FontWeight.bold)));
  }
}