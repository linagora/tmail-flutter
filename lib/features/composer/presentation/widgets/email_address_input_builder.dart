
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

class EmailAddressInputBuilder {

  final Key? keyInput;
  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ExpandMode expandMode;
  final PrefixEmailAddress _prefixEmailAddress;
  final List<EmailAddress> _listEmailAddress;

  OnOpenExpandAddressActionClick? _onOpenExpandAddressActionClick;
  OnUpdateListEmailAddressAction? _onUpdateListEmailAddressAction;
  OnSuggestionEmailAddress? _onSuggestionEmailAddress;

  void addExpandAddressActionClick(OnOpenExpandAddressActionClick onOpenExpandAddressActionClick) {
    _onOpenExpandAddressActionClick = onOpenExpandAddressActionClick;
  }

  void addOnUpdateListEmailAddressAction(OnUpdateListEmailAddressAction onUpdateListEmailAddressAction) {
    _onUpdateListEmailAddressAction = onUpdateListEmailAddressAction;
  }

  void addOnSuggestionEmailAddress(OnSuggestionEmailAddress onSuggestionEmailAddress) {
    _onSuggestionEmailAddress = onSuggestionEmailAddress;
  }

  EmailAddressInputBuilder(
    this._context,
    this._imagePaths,
    this._prefixEmailAddress,
    this._listEmailAddress,
    {
      this.keyInput,
      this.expandMode = ExpandMode.COLLAPSE,
    }
  );

  Widget build() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 8, top: _listEmailAddress.isNotEmpty ? 20 : 18),
            child: Text(
              '${_prefixEmailAddress.asName(_context)}:',
              style: TextStyle(fontSize: 14, color: AppColor.nameUserColor, fontWeight: FontWeight.w500))),
          Expanded(child: ChipsInput<EmailAddress>(
            key: keyInput,
            initialValue: _listEmailAddress,
            textStyle: TextStyle(color: AppColor.nameUserColor, fontSize: 14, fontWeight: FontWeight.w500),
            cursorColor: AppColor.primaryColor,
            inputType: TextInputType.emailAddress,
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
                _onUpdateListEmailAddressAction!(_prefixEmailAddress, data);
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
                  subtitle: emailAddress.displayName.isNotEmpty && emailAddress.emailAddress.isNotEmpty
                    ? Text(
                        emailAddress.emailAddress,
                        style: TextStyle(color: AppColor.baseTextColor, fontSize: 12, fontWeight: FontWeight.w500))
                    : null,
                  onTap: () => state.selectSuggestion(emailAddress),
                ),
              );
            }
          )),
          if (_prefixEmailAddress == PrefixEmailAddress.to)
            Padding(
              padding: EdgeInsets.only(top: _listEmailAddress.isNotEmpty ? 6 : 3),
              child: _buildButtonExpandAddress())
        ]
    );
  }

  Widget _buildButtonExpandAddress() {
    return IconButton(
      color: AppColor.baseTextColor,
      icon: SvgPicture.asset(
        expandMode == ExpandMode.EXPAND ? _imagePaths.icExpandAddress : _imagePaths.icMoreReceiver,
        width: 20,
        height: 20,
        fit: BoxFit.fill),
      onPressed: () {
        if (_onOpenExpandAddressActionClick != null) {
          _onOpenExpandAddressActionClick!();
        }
      }
    );
  }
}