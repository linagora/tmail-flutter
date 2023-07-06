
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:super_tag_editor/widgets/rich_text_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/suggestion_email_address.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_constants.dart';

typedef OnSuggestionEmailAddress = Future<List<EmailAddress>> Function(String word);
typedef OnUpdateListEmailAddressAction = void Function(PrefixEmailAddress, List<EmailAddress>);
typedef OnAddEmailAddressTypeAction = void Function(PrefixEmailAddress);
typedef OnDeleteEmailAddressTypeAction = void Function(PrefixEmailAddress);
typedef OnShowFullListEmailAddressAction = void Function(PrefixEmailAddress);
typedef OnFocusEmailAddressChangeAction = void Function(PrefixEmailAddress, bool);
typedef OnFocusNextAddressAction = void Function();

class EmailAddressInputBuilder {

  static const _suggestionBoxRadius = 20.0;
  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final ExpandMode expandMode;
  final PrefixEmailAddress _prefixEmailAddress;
  final List<PrefixEmailAddress> _listEmailAddressType;
  final TextEditingController? controller;
  final bool? isInitial;
  final FocusNode? focusNode;
  final bool autoDisposeFocusNode;
  final GlobalKey? keyTagEditor;
  final FocusNode? nextFocusNode;

  List<EmailAddress> listEmailAddress = <EmailAddress>[];

  OnUpdateListEmailAddressAction? _onUpdateListEmailAddressAction;
  OnSuggestionEmailAddress? _onSuggestionEmailAddress;
  OnAddEmailAddressTypeAction? _onAddEmailAddressTypeAction;
  OnDeleteEmailAddressTypeAction? _onDeleteEmailAddressTypeAction;
  OnShowFullListEmailAddressAction? _onShowFullListEmailAddressAction;
  OnFocusEmailAddressChangeAction? _onFocusEmailAddressChangeAction;
  OnFocusNextAddressAction? _onFocusNextAddressAction;

  Timer? _gapBetweenTagChangedAndFindSuggestion;
  bool lastTagFocused = false;

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

  void addOnFocusNextAddressAction(OnFocusNextAddressAction? onFocusNextAddressAction) {
    _onFocusNextAddressAction = onFocusNextAddressAction;
  }

  EmailAddressInputBuilder(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
    this._prefixEmailAddress,
    this.listEmailAddress,
    this._listEmailAddressType,
    {
      this.isInitial,
      this.controller,
      this.focusNode,
      this.autoDisposeFocusNode = true,
      this.expandMode = ExpandMode.EXPAND,
      this.keyTagEditor,
      this.nextFocusNode,
    }
  );

  Widget build() {
    return Padding(
      padding: _prefixEmailAddress == PrefixEmailAddress.to
        ? ComposerStyle.getToAddressPadding(_context, _responsiveUtils)
        : ComposerStyle.getCcBccAddressPadding(_context, _responsiveUtils),
      child: Row(
        children: [
          Text(
            '${_prefixEmailAddress.asName(_context)}:',
            style: const TextStyle(
              fontSize: 15,
              color: AppColor.colorHintEmailAddressInput
            )
          ),
          SizedBox(width: ComposerStyle.getSpace(_context, _responsiveUtils)),
          Expanded(child: _buildTagEditor()),
          SizedBox(width: ComposerStyle.getSpace(_context, _responsiveUtils)),
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
            ])
          else
            buildIconWeb(
              icon: SvgPicture.asset(
                _imagePaths.icCloseComposer,
                width: 28,
                height: 28,
                fit: BoxFit.fill
              ),
              iconPadding: EdgeInsets.zero,
              onTap: () => _onDeleteEmailAddressTypeAction?.call(_prefixEmailAddress))
        ]
      ),
    );
  }

  Widget _buildTagEditor() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      final newListEmailAddress = _isCollapse ? listEmailAddress.sublist(0, 1) : listEmailAddress;
      return FocusScope(child: Focus(
          onFocusChange: (focus) => _onFocusEmailAddressChangeAction?.call(_prefixEmailAddress, focus),
          onKey: (focusNode, event) {
            if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
              nextFocusNode?.requestFocus();
              _onFocusNextAddressAction?.call();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: TagEditor<SuggestionEmailAddress>(
            key: keyTagEditor,
            length: newListEmailAddress.length,
            controller: controller,
            focusNode: focusNode,
            autoDisposeFocusNode: autoDisposeFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            debounceDuration: const Duration(milliseconds: 150),
            hasAddButton: false,
            tagSpacing: 8,
            autofocus: _prefixEmailAddress != PrefixEmailAddress.to && listEmailAddress.isEmpty,
            minTextFieldWidth: 20,
            resetTextOnSubmitted: true,
            suggestionsBoxElevation: _suggestionBoxRadius,
            suggestionsBoxBackgroundColor: Colors.white,
            suggestionsBoxRadius: 20,
            suggestionsBoxMaxHeight: 350,
            textStyle: const TextStyle(color: AppColor.colorEmailAddress, fontSize: 14, fontWeight: FontWeight.w500),
            onFocusTagAction: (focused) {
              setState(() {
                lastTagFocused = focused;
              });
            },
            onDeleteTagAction: () => _handleDeleteTagAction(setState, context),
            onSelectOptionAction: (item) {
              if (!_isDuplicatedRecipient(item.emailAddress.emailAddress)) {
                setState(() => listEmailAddress.add(item.emailAddress));
                _onUpdateListEmailAddressAction?.call(_prefixEmailAddress, listEmailAddress);
              }
            },
            onSubmitted: (value) {
              log('EmailAddressInputBuilder::_buildTagEditor():onSubmitted: value: $value');
              final textTrim = value.trim();
              log('EmailAddressInputBuilder::_buildTagEditor():onSubmitted: textTrim: $textTrim');
              if (!_isDuplicatedRecipient(textTrim)) {
                setState(() => listEmailAddress.add(EmailAddress(null, textTrim)));
                _onUpdateListEmailAddressAction?.call(_prefixEmailAddress, listEmailAddress);
              }
            },
            inputDecoration: const InputDecoration(border: InputBorder.none),
            tagBuilder: (context, index) {
              final isLastEmail = index == listEmailAddress.length - 1;
              return Stack(
                alignment: AlignmentDirectional.centerEnd,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      top: PlatformInfo.isWeb ? 8 : 0,
                      end: _isCollapse ? 50 : 0),
                    child: InkWell(
                      onTap: () => _isCollapse
                        ? _onShowFullListEmailAddressAction?.call(_prefixEmailAddress)
                        : null,
                      child: Chip(
                        padding: DirectionUtils.isDirectionRTLByLanguage(context)
                          ? EdgeInsets.zero
                          : null,
                        labelPadding: EdgeInsetsDirectional.symmetric(
                          horizontal: 12,
                          vertical: DirectionUtils.isDirectionRTLByHasAnyRtl(newListEmailAddress[index].asString()) ? 0 : 2
                        ),
                        label: Text(
                          newListEmailAddress[index].asString(),
                          maxLines: 1,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                        ),
                        deleteIcon: SvgPicture.asset(_imagePaths.icClose, fit: BoxFit.fill),
                        labelStyle: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                        backgroundColor: _getTagBackgroundColor(listEmailAddress[index], isLastEmail),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: _getTagBorderSide(listEmailAddress[index], isLastEmail),
                        ),
                        avatar: newListEmailAddress[index].displayName.isNotEmpty
                          ? CircleAvatar(
                              backgroundColor: AppColor.colorTextButton,
                              child: Text(
                                listEmailAddress[index].displayName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500
                                )
                              ))
                          : null,
                        onDeleted: () {
                          setState(() => listEmailAddress.removeAt(index));
                          _onUpdateListEmailAddressAction?.call(_prefixEmailAddress, listEmailAddress);
                        },
                      )
                    )
                  ),
                  if (_isCollapse)
                    _buildCounter(
                      context,
                      listEmailAddress.length - newListEmailAddress.length
                    ),
                ]
              );
            },
            onTagChanged: (value) {
              log('EmailAddressInputBuilder::_buildTagEditor():onTagChanged: value: $value');
              final textTrim = value.trim();
              log('EmailAddressInputBuilder::_buildTagEditor():onTagChanged: textTrim: $textTrim');
              if (!_isDuplicatedRecipient(textTrim)) {
                setState(() => listEmailAddress.add(EmailAddress(null, textTrim)));
                _onUpdateListEmailAddressAction?.call(_prefixEmailAddress, listEmailAddress);
              }
              _gapBetweenTagChangedAndFindSuggestion = Timer(
                const Duration(seconds: 1),
                _handleGapBetweenTagChangedAndFindSuggestion);
            },
            findSuggestions: _findSuggestions,
            useDefaultHighlight: false,
            suggestionBuilder: (
              context,
              tagEditorState,
              suggestionEmailAddress,
              index,
              length,
              highlight,
              suggestionValid
            ) {
              switch (suggestionEmailAddress.state) {
                case SuggestionEmailState.duplicated:
                  return _buildExistedSuggestionItem(
                    setState,
                    context,
                    suggestionEmailAddress.emailAddress,
                    suggestionValid
                  );
                default:
                  return _buildSuggestionItem(
                    setState,
                    context,
                    tagEditorState,
                    suggestionEmailAddress.emailAddress,
                    index,
                    length,
                    highlight,
                    suggestionValid
                  );
              }
            },
          )
      ));
    });
  }

  Widget _buildCounter(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8, top: PlatformInfo.isWeb ? 8 : 0),
      child: InkWell(
        onTap: () => _onShowFullListEmailAddressAction?.call(_prefixEmailAddress),
        child: Chip(
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          label: Text(
            '+$count',
            maxLines: 1,
            overflow: CommonTextStyle.defaultTextOverFlow,
            softWrap: CommonTextStyle.defaultSoftWrap),
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

  Widget _buildExistedSuggestionItem(
    StateSetter setState,
    BuildContext context,
    EmailAddress emailAddress,
    String? suggestionValid
  ) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(_suggestionBoxRadius))),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColor.colorBgMenuItemDropDownSelected,
          borderRadius: BorderRadius.all(Radius.circular(_suggestionBoxRadius))),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          leading: _buildAvatarSuggestionItem(emailAddress),
          title: _buildTitleSuggestionItem(emailAddress, suggestionValid),
          subtitle: _buildSubtitleSuggestionItem(emailAddress, suggestionValid),
          trailing: SvgPicture.asset(_imagePaths.icFilterSelected,
            width: 24,
            height: 24,
            fit: BoxFit.fill),
        )
      )
    );
  }

  Widget _buildSuggestionItem(
    StateSetter setState,
    BuildContext context,
    TagsEditorState<SuggestionEmailAddress> tagEditorState,
    EmailAddress emailAddress,
    int index,
    int length,
    bool highlight,
    String? suggestionValid
  ) {
    return Container(
      color: highlight ? AppColor.colorItemSelected : Colors.white,
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: _buildAvatarSuggestionItem(emailAddress),
          title: _buildTitleSuggestionItem(emailAddress, suggestionValid),
          subtitle: _buildSubtitleSuggestionItem(emailAddress, suggestionValid),
          onTap: () {
            setState(() => listEmailAddress.add(emailAddress));
            _onUpdateListEmailAddressAction?.call(_prefixEmailAddress, listEmailAddress);
            tagEditorState.resetTextField();
            tagEditorState.closeSuggestionBox();
          },
        ),
      ),
    );
  }

  Widget _buildAvatarSuggestionItem(EmailAddress emailAddress) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.avatarColor,
        border: Border.all(
          color: AppColor.colorShadowBgContentEmail,
          width: 1.0
        )
      ),
      child: Text(
        emailAddress.asString().isNotEmpty
          ? emailAddress.asString()[0].toUpperCase()
          : '',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w600
        )
      )
    );
  }

  Widget _buildTitleSuggestionItem(EmailAddress emailAddress, String? suggestionValid) {
    return RichTextWidget(
      textOrigin: emailAddress.asString(),
      wordSearched: suggestionValid ?? ''
    );
  }

  Widget? _buildSubtitleSuggestionItem(EmailAddress emailAddress, String? suggestionValid) {
    if (emailAddress.displayName.isNotEmpty && emailAddress.emailAddress.isNotEmpty) {
      return RichTextWidget(
        textOrigin: emailAddress.emailAddress,
        wordSearched: suggestionValid ?? '',
        styleTextOrigin: const TextStyle(
          color: AppColor.colorHintSearchBar,
          fontSize: 13,
          fontWeight: FontWeight.normal
        ),
        styleWordSearched: const TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.bold
        )
      );
    } else {
      return null;
    }
  }

  FutureOr<List<SuggestionEmailAddress>> _findSuggestions(String query) async {
    log('EmailAddressInputBuilder::_findSuggestions():query: $query');
    if (_gapBetweenTagChangedAndFindSuggestion?.isActive ?? false) {
      log('EmailAddressInputBuilder::_findSuggestions(): return empty');
      return [];
    }

    final processedQuery = query.trim();
    if (processedQuery.isEmpty) {
      return [];
    }

    final tmailSuggestion = List<SuggestionEmailAddress>.empty(growable: true);
    if (processedQuery.length >= AppConstants.limitCharToStartSearch && _onSuggestionEmailAddress != null) {
      tmailSuggestion.addAll(
        (await _onSuggestionEmailAddress!(processedQuery))
          .map((emailAddress) => _toSuggestionEmailAddress(emailAddress, listEmailAddress)));
    }

    tmailSuggestion.addAll(_matchedSuggestionEmailAddress(processedQuery, listEmailAddress));

    final currentTextOnTextField = controller?.text ?? '';
    if (currentTextOnTextField.isEmpty) {
      return [];
    }

    return tmailSuggestion.toSet().toList();
  }

  bool _isEmailAddressValid(String emailAddress) => GetUtils.isEmail(emailAddress);

  bool _isDuplicatedRecipient(String inputEmail) {
    if (inputEmail.isEmpty) {
      return false;
    }
    return listEmailAddress
      .map((emailAddress) => emailAddress.email)
      .whereNotNull()
      .contains(inputEmail);
  }

  SuggestionEmailAddress _toSuggestionEmailAddress(EmailAddress item, List<EmailAddress> addedEmailAddresses) {
    if (addedEmailAddresses.contains(item)) {
      return SuggestionEmailAddress(item, state: SuggestionEmailState.duplicated);
    } else {
      return SuggestionEmailAddress(item);
    }
  }

  Iterable<SuggestionEmailAddress> _matchedSuggestionEmailAddress(String query, List<EmailAddress> addedEmailAddress) {
    return addedEmailAddress.where((addedMail) => addedMail.emailAddress.contains(query))
      .map((emailAddress) => SuggestionEmailAddress(emailAddress, state: SuggestionEmailState.duplicated));
  }

  void _handleGapBetweenTagChangedAndFindSuggestion() {
    log('EmailAddressInputBuilder::_handleGapBetweenTagChangedAndFindSuggestion(): Timeout');
  }

  Color _getTagBackgroundColor(EmailAddress emailCurrent, bool isLastEmail) {
    if (lastTagFocused && isLastEmail) {
      return AppColor.colorItemRecipientSelected;
    } else {
      return _isEmailAddressValid(emailCurrent.emailAddress)
        ? AppColor.colorEmailAddressTag
        : Colors.white;
    }
  }

  BorderSide _getTagBorderSide(EmailAddress emailCurrent, bool isLastEmail) {
    if (lastTagFocused && isLastEmail) {
      return const BorderSide(
        width: 1,
        color: AppColor.primaryColor);
    } else {
      return BorderSide(
        width: _isEmailAddressValid(emailCurrent.emailAddress) ? 0 : 1,
        color: _isEmailAddressValid(emailCurrent.emailAddress)
          ? AppColor.colorEmailAddressTag
          : AppColor.colorBorderEmailAddressInvalid);
    }
  }

  void _handleDeleteTagAction(StateSetter setState, BuildContext context) {
    log('EmailAddressInputBuilder::_handleDeleteTagAction()');
    if (listEmailAddress.isNotEmpty) {
      setState(() {
        listEmailAddress.removeLast();
      });
      _onUpdateListEmailAddressAction?.call(_prefixEmailAddress, listEmailAddress);
    }
  }
}