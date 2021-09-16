
import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnOpenExpandAddressActionClick = void Function();
typedef OnSuggestionEmailAddress = Future<List<EmailAddress>> Function(String word);
typedef OnUpdateListEmailAddressAction = void Function(
  PrefixEmailAddress prefixEmailAddress,
  List<EmailAddress> listEmailAddress
);

class EmailAddressComposerWidgetBuilder {

  final ImagePaths _imagePaths;
  final BuildContext _context;
  final ExpandMode _expandMode;
  final List<EmailAddress> _listToEmailAddress;
  final List<EmailAddress> _listCcEmailAddress;
  final List<EmailAddress> _listBccEmailAddress;
  final UserProfile? _userProfile;

  final keyToEmailAddress = new GlobalKey<ChipsInputState>();

  OnOpenExpandAddressActionClick? _onOpenExpandAddressActionClick;
  OnUpdateListEmailAddressAction? _onUpdateListEmailAddressAction;
  OnSuggestionEmailAddress? _onSuggestionEmailAddress;

  EmailAddressComposerWidgetBuilder(
    this._context,
    this._imagePaths,
    this._expandMode,
    this._listToEmailAddress,
    this._listCcEmailAddress,
    this._listBccEmailAddress,
    this._userProfile,
  );

  void addExpandAddressActionClick(OnOpenExpandAddressActionClick onOpenExpandAddressActionClick) {
    _onOpenExpandAddressActionClick = onOpenExpandAddressActionClick;
  }

  void addOnUpdateListEmailAddressAction(OnUpdateListEmailAddressAction onUpdateListEmailAddressAction) {
    _onUpdateListEmailAddressAction = onUpdateListEmailAddressAction;
  }

  void addOnSuggestionEmailAddress(OnSuggestionEmailAddress onSuggestionEmailAddress) {
    _onSuggestionEmailAddress = onSuggestionEmailAddress;
  }

  Widget build() {
    keyToEmailAddress.currentState?.selectSuggestion(_listToEmailAddress);

    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent),
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text(
                      '${AppLocalizations.of(_context).from_email_address_prefix}:',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(fontSize: 14, color: AppColor.nameUserColor, fontWeight: FontWeight.w500))),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '<${_userProfile?.email}>',
                          style: TextStyle(fontSize: 14, color: AppColor.nameUserColor)
                        )
                      ],
                    )
                  )
              ])),
            _buildEmailAddressWidget(PrefixEmailAddress.to, hasExpandButton: true),
            if (_expandMode == ExpandMode.EXPAND) _buildEmailAddressWidget(PrefixEmailAddress.cc),
            if (_expandMode == ExpandMode.EXPAND) _buildEmailAddressWidget(PrefixEmailAddress.bcc),
          ],
        )
      )
    );
  }

  Widget _buildEmailAddressWidget(PrefixEmailAddress prefixEmailAddress, {bool hasExpandButton = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8, top: _paddingTo(prefixEmailAddress)),
          child: Text(
            '${prefixEmailAddress.asName(_context)}:',
            style: TextStyle(fontSize: 14, color: AppColor.nameUserColor, fontWeight: FontWeight.w500))),
        Expanded(child: ChipsInput<EmailAddress>(
          key: prefixEmailAddress == PrefixEmailAddress.to
            ? keyToEmailAddress
            : Key('${prefixEmailAddress.toString()}_email_address_input'),
          initialValue: _getListEmailAddressCurrent(prefixEmailAddress),
          textStyle: TextStyle(color: AppColor.nameUserColor, fontSize: 14, fontWeight: FontWeight.w500),
          cursorColor: AppColor.primaryColor,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: AppLocalizations.of(_context).hint_text_email_address,
            hintMaxLines: 1,
            hintStyle: TextStyle(color: AppColor.baseTextColor, fontSize: 14, fontWeight: FontWeight.w500)),
          findSuggestions: (query) {
            if (query.isNotEmpty && _onSuggestionEmailAddress != null) {
              return _onSuggestionEmailAddress!(query);
            }
            return [];
          },
          onChanged: (data) {
            if (_onUpdateListEmailAddressAction != null) {
              _onUpdateListEmailAddressAction!(prefixEmailAddress, data);
            }
          },
          onChipInputActionDone: (state, value) {
            if (GetUtils.isEmail(value)) {
              state.selectSuggestion(EmailAddress(value, value));
            }
          },
          onChipInputChangeFocusAction: (state, value) {
            if (GetUtils.isEmail(value)) {
              state.selectSuggestion(EmailAddress(value, value));
            }
          },
          chipBuilder: (context, state, emailAddress) {
            return InputChip(
              key: ObjectKey(emailAddress),
              label: Text(emailAddress.asString()),
              labelStyle: TextStyle(color: AppColor.nameUserColor, fontSize: 12, fontWeight: FontWeight.w500),
              backgroundColor: AppColor.emailAddressChipColor,
              padding: EdgeInsets.all(3),
              deleteIconColor: AppColor.baseTextColor,
              avatar: CircleAvatar(
                backgroundColor: AppColor.avatarColor,
                child: Text(
                  emailAddress.asString().isNotEmpty ? emailAddress.asString()[0].toUpperCase() : '',
                  style: TextStyle(color: AppColor.appColor, fontSize: 12, fontWeight: FontWeight.w500))),
              onDeleted: () => state.deleteChip(emailAddress),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          },
          suggestionBuilder: (context, state, emailAddress) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white),
                color: Colors.white),
              child: ListTile(
                key: ObjectKey(emailAddress),
                leading: CircleAvatar(
                  backgroundColor: AppColor.avatarColor,
                  child: Text(
                    emailAddress.asString().isNotEmpty ? emailAddress.asString()[0].toUpperCase() : '',
                    style: TextStyle(color: AppColor.appColor, fontSize: 16, fontWeight: FontWeight.w500))),
                title: Text(
                  emailAddress.asString(),
                  style: TextStyle(color: AppColor.nameUserColor, fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: emailAddress.getName().isNotEmpty && emailAddress.getEmail().isNotEmpty
                  ? Text(
                      emailAddress.getEmail(),
                      style: TextStyle(color: AppColor.baseTextColor, fontSize: 12, fontWeight: FontWeight.w500))
                  : null,
                onTap: () => state.selectSuggestion(emailAddress),
              ),
            );
          })),
        if (hasExpandButton) _buildButtonExpandAddress()
      ]
    );
  }

  Widget _buildButtonExpandAddress() {
    return GestureDetector(
      onTap: () {
        if (_onOpenExpandAddressActionClick != null) {
          _onOpenExpandAddressActionClick!();
        }},
      child: Padding(
        padding: EdgeInsets.only(top: 20),
        child: SvgPicture.asset(
          _expandMode == ExpandMode.EXPAND ? _imagePaths.icExpandAddress : _imagePaths.icMoreReceiver,
          width: 20,
          height: 20,
          fit: BoxFit.fill),
      ),
    );
  }

  List<EmailAddress> _getListEmailAddressCurrent(PrefixEmailAddress prefixEmailAddress) {
    switch(prefixEmailAddress) {
      case PrefixEmailAddress.to:
        return _listToEmailAddress;
      case PrefixEmailAddress.cc:
        return _listCcEmailAddress;
      case PrefixEmailAddress.bcc:
        return _listBccEmailAddress;
    }
  }

  double _paddingTo(PrefixEmailAddress prefixEmailAddress) {
    switch(prefixEmailAddress) {
      case PrefixEmailAddress.to:
        return _listToEmailAddress.isNotEmpty ? 20 : 18;
      case PrefixEmailAddress.cc:
        return _listCcEmailAddress.isNotEmpty ? 20 : 18;
      case PrefixEmailAddress.bcc:
        return _listBccEmailAddress.isNotEmpty ? 20 : 18;
    }
  }
}