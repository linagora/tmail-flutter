
import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:material_tag_editor/tag_editor.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnOpenExpandAddressActionClick = void Function();
typedef OnSuggestionEmailAddress = Future<List<EmailAddress>> Function(String word);
typedef OnUpdateListEmailAddressAction = void Function(PrefixEmailAddress, List<EmailAddress>);

class EmailAddressInputBuilder {

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final AppToast _appToast;
  final ExpandMode expandMode;
  final PrefixEmailAddress _prefixEmailAddress;
  final List<EmailAddress> _listEmailAddress;
  final TextEditingController? controller;
  final bool? isInitial;
  final bool hasAvatar;

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
    this._appToast,
    this._prefixEmailAddress,
    this._listEmailAddress,
    {
      this.isInitial,
      this.hasAvatar = false,
      this.controller,
      this.expandMode = ExpandMode.COLLAPSE,
    }
  );

  Widget build() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8, top: 15),
          child: Text(
            '${_prefixEmailAddress.asName(_context)}:',
            style: TextStyle(fontSize: 15, color: AppColor.colorHintEmailAddressInput))),
        Expanded(child: _buildTagEditor()),
        if (_prefixEmailAddress == PrefixEmailAddress.to)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: _buildButtonExpandAddress())
      ]
    );
  }

  Widget _buildButtonExpandAddress() {
    return Material(
        type: MaterialType.circle,
        color: Colors.transparent,
        child: TextButton(
            child: Text(
                expandMode == ExpandMode.EXPAND ? AppLocalizations.of(_context).hide : AppLocalizations.of(_context).details,
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: AppColor.colorTextButton)),
            onPressed: () => _onOpenExpandAddressActionClick?.call()
        )
    );
  }

  Widget _buildTagEditor() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return TagEditor<EmailAddress>(
        length: _listEmail.length,
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        hasAddButton: false,
        tagSpacing: 8,
        resetTextOnSubmitted: true,
        textStyle: TextStyle(color: AppColor.colorEmailAddress, fontSize: 14, fontWeight: FontWeight.w500),
        onSubmitted: (value) {
          if (GetUtils.isEmail(value)) {
            setState(() => _listEmailAddress.add(EmailAddress(value, value)));
            _onUpdateListEmailAddressAction?.call(_prefixEmailAddress, _listEmailAddress);
          } else {
            _appToast.showErrorToast(AppLocalizations.of(context).email_address_is_not_in_the_correct_format);
          }
        },
        inputDecoration: InputDecoration(
            border: InputBorder.none,
            hintText: AppLocalizations.of(_context).hint_text_email_address,
            hintMaxLines: 1,
            hintStyle: TextStyle(color: AppColor.colorHintEmailAddressInput, fontSize: 14, fontWeight: FontWeight.w500)
        ),
        tagBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(top: kIsWeb ? 8 : 0),
            child: Chip(
              labelPadding: EdgeInsets.only(left: 12, right: 12, bottom: 2),
              label: Text(_listEmail[index], maxLines: 1, overflow: TextOverflow.ellipsis),
              deleteIcon: SvgPicture.asset(_imagePaths.icDeleteEmailAddress, fit: BoxFit.fill),
              labelStyle: TextStyle(color: AppColor.colorEmailAddress, fontSize: 14, fontWeight: FontWeight.w500),
              backgroundColor: AppColor.emailAddressChipColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(width: 0, color: AppColor.emailAddressChipColor),
              ),
              avatar: hasAvatar == true
                  ? CircleAvatar(
                    backgroundColor: AppColor.colorTextButton,
                    child: Text(
                        _listEmail[index].isNotEmpty ? _listEmail[index][0].toUpperCase() : '',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)))
                  : null,
              onDeleted: () {
                setState(() => _listEmailAddress.removeAt(index));
                _onUpdateListEmailAddressAction?.call(_prefixEmailAddress, _listEmailAddress);
              },
            )),
        onTagChanged: (String value) {},
        findSuggestions: (String query) {
          if (query.isNotEmpty && _onSuggestionEmailAddress != null) {
            return _onSuggestionEmailAddress!(query);
          }
          return [];
        },
        suggestionBuilder: (context, tagEditorState, emailAddress) {
          return _buildSuggestionItem(setState, context, tagEditorState, emailAddress);
        },
      );
    });
  }

  List<String> get _listEmail => _listEmailAddress.map((emailAddress) => emailAddress.asString()).toList();

  Widget _buildSuggestionItem(StateSetter setState, BuildContext context, TagsEditorState<EmailAddress> tagEditorState, EmailAddress emailAddress) {
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
        onTap: () {
          setState(() => _listEmailAddress.add(emailAddress));
          tagEditorState.selectSuggestion(emailAddress);
          _onUpdateListEmailAddressAction?.call(_prefixEmailAddress, _listEmailAddress);
        },
      ),
    );
  }
}