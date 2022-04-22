
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

typedef OnSuggestionEmailAddress = Future<List<EmailAddress>> Function(String word);
typedef OnUpdateListEmailAddressAction = void Function(PrefixEmailAddress, List<EmailAddress>);
typedef OnAddEmailAddressTypeAction = void Function(PrefixEmailAddress);
typedef OnDeleteEmailAddressTypeAction = void Function(PrefixEmailAddress);
typedef OnShowFullListEmailAddressAction = void Function(PrefixEmailAddress);
typedef OnFocusEmailAddressChangeAction = void Function(PrefixEmailAddress, bool);
typedef OnOpenSuggestionBoxEmailAddress = Future<List<EmailAddress>> Function();

class EmailAddressInputBuilder {

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ExpandMode expandMode;
  final PrefixEmailAddress _prefixEmailAddress;
  final List<PrefixEmailAddress> _listEmailAddressType;
  final TextEditingController? controller;
  final bool? isInitial;

  List<EmailAddress> listEmailAddress = <EmailAddress>[];

  OnUpdateListEmailAddressAction? _onUpdateListEmailAddressAction;
  OnSuggestionEmailAddress? _onSuggestionEmailAddress;
  OnAddEmailAddressTypeAction? _onAddEmailAddressTypeAction;
  OnDeleteEmailAddressTypeAction? _onDeleteEmailAddressTypeAction;
  OnShowFullListEmailAddressAction? _onShowFullListEmailAddressAction;
  OnFocusEmailAddressChangeAction? _onFocusEmailAddressChangeAction;
  OnOpenSuggestionBoxEmailAddress? _onOpenSuggestionBoxEmailAddress;

  void addOnUpdateListEmailAddressAction(OnUpdateListEmailAddressAction onUpdateListEmailAddressAction) {
    _onUpdateListEmailAddressAction = onUpdateListEmailAddressAction;
  }

  void addOnSuggestionEmailAddress(OnSuggestionEmailAddress onSuggestionEmailAddress) {
    _onSuggestionEmailAddress = onSuggestionEmailAddress;
  }

  void addOnAddEmailAddressTypeAction(OnAddEmailAddressTypeAction onAddEmailAddressTypeAction) {
    _onAddEmailAddressTypeAction = onAddEmailAddressTypeAction;
  }

  void addOnDeleteEmailAddressTypeAction(OnDeleteEmailAddressTypeAction onDeleteEmailAddressTypeAction) {
    _onDeleteEmailAddressTypeAction = onDeleteEmailAddressTypeAction;
  }

  void addOnShowFullListEmailAddressAction(OnShowFullListEmailAddressAction onShowFullListEmailAddressAction) {
    _onShowFullListEmailAddressAction = onShowFullListEmailAddressAction;
  }

  void addOnFocusEmailAddressChangeAction(OnFocusEmailAddressChangeAction onFocusEmailAddressChangeAction) {
    _onFocusEmailAddressChangeAction = onFocusEmailAddressChangeAction;
  }

  void addOnOpenSuggestionBoxEmailAddress(OnOpenSuggestionBoxEmailAddress onOpenSuggestionBoxEmailAddress) {
    _onOpenSuggestionBoxEmailAddress = onOpenSuggestionBoxEmailAddress;
  }

  EmailAddressInputBuilder(
    this._context,
    this._imagePaths,
    this._prefixEmailAddress,
    this.listEmailAddress,
    this._listEmailAddressType,
    {
      this.isInitial,
      this.controller,
      this.expandMode = ExpandMode.EXPAND,
    }
  );

  Widget build() {
    return Row(
      children: [
        Text('${_prefixEmailAddress.asName(_context)}:',
          style: const TextStyle(fontSize: 15, color: AppColor.colorHintEmailAddressInput)),
        Expanded(child: Padding(
            padding: EdgeInsets.only(right: _listEmailAddressType.length == 2 ? 8 : 8),
            child: _buildTagEditor())),
        if (_prefixEmailAddress == PrefixEmailAddress.to)
          Row(children: [
            if (!_listEmailAddressType.contains(PrefixEmailAddress.cc))
              buildTextIcon(AppLocalizations.of(_context).cc_email_address_prefix,
                padding: const EdgeInsets.all(5),
                textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.underline,
                color: AppColor.lineItemListColor),
                onTap: () => _onAddEmailAddressTypeAction?.call(PrefixEmailAddress.cc)),
            if (!_listEmailAddressType.contains(PrefixEmailAddress.bcc))
              buildTextIcon(AppLocalizations.of(_context).bcc_email_address_prefix,
                  padding: const EdgeInsets.all(5),
                  textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.underline,
                      color: AppColor.lineItemListColor),
                  onTap: () => _onAddEmailAddressTypeAction?.call(PrefixEmailAddress.bcc)),
            const SizedBox(width: 10),
          ]),
        if (_prefixEmailAddress != PrefixEmailAddress.to)
          buildIconWeb(
              icon: SvgPicture.asset(_imagePaths.icCloseComposer, fit: BoxFit.fill),
              onTap: () => _onDeleteEmailAddressTypeAction?.call(_prefixEmailAddress))
      ]
    );
  }

  Widget _buildTagEditor() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      final newListEmailAddress = _isCollapse ? listEmailAddress.sublist(0, 1) : listEmailAddress;
      return FocusScope(child: Focus(
          onFocusChange: (focus) => _onFocusEmailAddressChangeAction?.call(_prefixEmailAddress, focus),
          child: TagEditor<EmailAddress>(
            length: newListEmailAddress.length,
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            hasAddButton: false,
            tagSpacing: 8,
            delimiters: const [' '],
            autofocus: _prefixEmailAddress != PrefixEmailAddress.to,
            minTextFieldWidth: 20,
            resetTextOnSubmitted: true,
            suggestionsBoxElevation: 20,
            suggestionsBoxBackgroundColor: Colors.white,
            suggestionsBoxRadius: 20,
            iconSuggestionBox: SvgPicture.asset(_imagePaths.icAddEmailAddress, fit: BoxFit.fill),
            textStyle: const TextStyle(color: AppColor.colorEmailAddress, fontSize: 14, fontWeight: FontWeight.w500),
            onSubmitted: (value) {
              setState(() => listEmailAddress.add(EmailAddress(null, value)));
              _onUpdateListEmailAddressAction?.call(_prefixEmailAddress, listEmailAddress);
            },
            inputDecoration: const InputDecoration(border: InputBorder.none),
            tagBuilder: (context, index) => Stack(alignment: Alignment.centerRight, children: [
              Padding(
                  padding: EdgeInsets.only(top: kIsWeb ? 8 : 0, right: _isCollapse ? 50 : 0),
                  child: InkWell(
                      onTap: () => _isCollapse ? _onShowFullListEmailAddressAction?.call(_prefixEmailAddress) : null,
                      child: Chip(
                        labelPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 2),
                        label: Text(newListEmailAddress[index].asString(), maxLines: 1, overflow: kIsWeb ? null : TextOverflow.ellipsis),
                        deleteIcon: SvgPicture.asset(_imagePaths.icClose, fit: BoxFit.fill),
                        labelStyle: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                        backgroundColor: _isEmailAddressValid(listEmailAddress[index].emailAddress) ? AppColor.colorEmailAddressTag : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                              width: _isEmailAddressValid(listEmailAddress[index].emailAddress) ? 0 : 1,
                              color: _isEmailAddressValid(listEmailAddress[index].emailAddress) ? AppColor.colorEmailAddressTag : AppColor.colorBorderEmailAddressInvalid),
                        ),
                        avatar: newListEmailAddress[index].displayName.isNotEmpty
                            ? CircleAvatar(
                                backgroundColor: AppColor.colorTextButton,
                                child: Text(
                                    listEmailAddress[index].displayName[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)))
                            : null,
                        onDeleted: () {
                          setState(() => listEmailAddress.removeAt(index));
                          _onUpdateListEmailAddressAction?.call(_prefixEmailAddress, listEmailAddress);
                        },
                      )
                  )
              ),
              if (_isCollapse) _buildCounter(context, listEmailAddress.length - newListEmailAddress.length),
            ]),
            onTagChanged: (String value) {
              setState(() => listEmailAddress.add(EmailAddress(null, value)));
              _onUpdateListEmailAddressAction?.call(_prefixEmailAddress, listEmailAddress);
            },
            findSuggestions: (String query) {
              if (query.trim().isNotEmpty && _onSuggestionEmailAddress != null) {
                return _onSuggestionEmailAddress!(query.trim());
              }
              return [];
            },
            searchAllSuggestions: () {
              if (_onOpenSuggestionBoxEmailAddress != null) {
                return _onOpenSuggestionBoxEmailAddress!();
              }
              return [];
            },
            suggestionBuilder: (context, tagEditorState, emailAddress) {
              return _buildSuggestionItem(setState, context, tagEditorState, emailAddress);
            },
          )
      ));
    });
  }

  Widget _buildCounter(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: kIsWeb ? 8 : 0),
      child: InkWell(
        onTap: () => _onShowFullListEmailAddressAction?.call(_prefixEmailAddress),
        child: Chip(
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          label: Text('+$count', maxLines: 1, overflow: kIsWeb ? null : TextOverflow.ellipsis),
          labelStyle: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
          backgroundColor: AppColor.colorEmailAddressTag,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(width: 0, color: AppColor.colorEmailAddressTag),
          ),
        ),
      ),
    );
  }

  bool get _isCollapse {
    return listEmailAddress.length > 1 && expandMode == ExpandMode.COLLAPSE;
  }

  Widget _buildSuggestionItem(StateSetter setState, BuildContext context, TagsEditorState<EmailAddress> tagEditorState, EmailAddress emailAddress) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColor.avatarColor,
          border: Border.all(color: AppColor.colorShadowBgContentEmail, width: 1.0)),
        child: Text(
            emailAddress.asString().isNotEmpty ? emailAddress.asString()[0].toUpperCase() : '',
            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))),
      title: Text(
          emailAddress.asString(),
          maxLines: 1,
          overflow: kIsWeb ? null : TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal)),
      subtitle: emailAddress.displayName.isNotEmpty && emailAddress.emailAddress.isNotEmpty
          ? Text(
              emailAddress.emailAddress,
              maxLines: 1,
              overflow: kIsWeb ? null : TextOverflow.ellipsis,
              style: const TextStyle(color: AppColor.colorHintSearchBar, fontSize: 13, fontWeight: FontWeight.normal))
          : null,
      onTap: () {
        setState(() => listEmailAddress.add(emailAddress));
        _onUpdateListEmailAddressAction?.call(_prefixEmailAddress, listEmailAddress);
        tagEditorState.selectSuggestion(emailAddress);
      },
    );
  }

  bool _isEmailAddressValid(String emailAddress) => GetUtils.isEmail(emailAddress);
}