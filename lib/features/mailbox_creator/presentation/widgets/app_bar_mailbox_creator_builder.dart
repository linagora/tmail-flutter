
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
        color: Colors.white,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          _buildCancelButton(),
          Expanded(child: _buildTitle()),
          _buildCreateButton()
        ])
    );
  }

  Widget _buildCancelButton() {
    return Material(
        borderRadius: BorderRadius.circular(20),
        color: Colors.transparent,
        child: TextButton(
            child: Text(
              AppLocalizations.of(_context).cancel,
              style: ThemeUtils.defaultTextStyleInterFont.copyWith(fontSize: 17, color: AppColor.colorTextButton),
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
              style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                  fontSize: 17,
                  color: isValidated
                      ? AppColor.colorTextButton
                      : AppColor.colorDisableMailboxCreateButton),
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
        maxLines: 1,
        softWrap: CommonTextStyle.defaultSoftWrap,
        overflow: CommonTextStyle.defaultTextOverFlow,
        style: ThemeUtils.defaultTextStyleInterFont.copyWith(
            fontSize: 20,
            color: AppColor.colorNameEmail,
            fontWeight: FontWeight.bold)));
  }
}