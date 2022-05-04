
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnCloseActionClick = void Function();

class AppBarDestinationPickerBuilder {
  OnCloseActionClick? _onCloseActionClick;

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final MailboxActions? _mailboxAction;

  AppBarDestinationPickerBuilder(
      this._context,
      this._imagePaths,
      this._mailboxAction,
  );

  void addCloseActionClick(OnCloseActionClick onCloseActionClick) {
    _onCloseActionClick = onCloseActionClick;
  }

  Widget build() {
    return Container(
        key: const Key('app_bar_destination_picker'),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: Colors.white),
        height: 52,
        child: MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.zero),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildBackButton(),
                  Expanded(child: _buildTitle()),
                   _buildCancelButton(),
                ]
            )
        )
    );
  }

  Widget _buildCancelButton() {
    if (_mailboxAction == MailboxActions.moveEmail) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Material(
            borderRadius: BorderRadius.circular(20),
            color: Colors.transparent,
            child: TextButton(
                child: Text(
                    AppLocalizations.of(_context).cancel,
                    style: const TextStyle(fontSize: 17, color: AppColor.colorTextButton)),
                onPressed: () => _onCloseActionClick?.call()
            )
        ));
    } else {
      return const SizedBox(width: 40, height: 40);
    }
  }

  Widget _buildBackButton() {
    if (_mailboxAction == MailboxActions.create) {
      return buildIconWeb(
          icon: SvgPicture.asset(_imagePaths.icBack, color: AppColor.colorTextButton, fit: BoxFit.fill),
          onTap: () => _onCloseActionClick?.call());
    } else {
      return const SizedBox(width: 100, height: 40);
    }
  }

  Widget _buildTitle() {
    return Text(
        _mailboxAction?.getTitle(_context) ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, color: AppColor.colorNameEmail, fontWeight: FontWeight.w700));
  }
}