
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/button_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/suggestion_email_address.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/contact_input_tag_item.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/contact_suggestion_box_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSuggestionContactCallbackAction = Future<List<EmailAddress>> Function(String query);
typedef OnAddListContactCallbackAction = Function(List<EmailAddress> listEmailAddress);
typedef OnExceptionAddListContactCallbackAction = Function();

class AutocompleteContactTextFieldWithTags extends StatefulWidget {

  final List<EmailAddress> listEmailAddress;
  final TextEditingController? controller;
  final bool? hasAddContactButton;
  final OnSuggestionContactCallbackAction? onSuggestionCallback;
  final OnAddListContactCallbackAction? onAddContactCallback;
  final OnExceptionAddListContactCallbackAction? onExceptionCallback;

  const AutocompleteContactTextFieldWithTags(this.listEmailAddress, {
    Key? key,
    this.controller,
    this.hasAddContactButton = false,
    this.onSuggestionCallback,
    this.onAddContactCallback,
    this.onExceptionCallback
  }) : super(key: key);

  @override
  State<AutocompleteContactTextFieldWithTags> createState() => _AutocompleteContactTextFieldWithTagsState();
}

class _AutocompleteContactTextFieldWithTagsState extends State<AutocompleteContactTextFieldWithTags> {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  late List<EmailAddress> listEmailAddress;
  late Timer _gapBetweenTagChangedAndFindSuggestion;

  @override
  void initState() {
    super.initState();
    listEmailAddress = widget.listEmailAddress;
    _gapBetweenTagChangedAndFindSuggestion = Timer(
      const Duration(microseconds: 500),
      () {}
    );
  }

  @override
  void dispose() {
    _gapBetweenTagChangedAndFindSuggestion.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemTagEditor = TagEditor<SuggestionEmailAddress>(
      length: listEmailAddress.length,
      controller: widget.controller,
      borderRadius: 12,
      backgroundColor: AppColor.colorInputBackgroundCreateMailbox,
      focusedBorderColor: AppColor.colorTextButton,
      enableBorderColor: AppColor.colorInputBorderCreateMailbox,
      cursorColor: AppColor.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      suggestionPadding: const EdgeInsets.symmetric(vertical: 12),
      suggestionMargin: const EdgeInsets.symmetric(vertical: 4),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      hasAddButton: false,
      tagSpacing: 12,
      delimiters: const [' '],
      autofocus: false,
      minTextFieldWidth: 20,
      resetTextOnSubmitted: true,
      suggestionsBoxBackgroundColor: Colors.white,
      suggestionsBoxRadius: 16,
      suggestionsBoxMaxHeight: 350,
      onSubmitted: (value) {
        if (!_isDuplicatedRecipient(value)) {
          setState(() => listEmailAddress.add(EmailAddress(null, value)));
        }
      },
      textStyle: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w500),
      inputDecoration: const InputDecoration(border: InputBorder.none),
      tagBuilder: (context, index) => ContactInputTagItem(
        listEmailAddress[index],
        deleteContactCallbackAction: (contact) {
          setState(() => listEmailAddress.remove(contact));
        }
      ),
      onTagChanged: (value) {
        if (!_isDuplicatedRecipient(value)) {
          setState(() => listEmailAddress.add(EmailAddress(null, value)));
        }
      },
      findSuggestions: _findSuggestions,
      suggestionBuilder: (context, tagEditorState, suggestionEmailAddress) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ContactSuggestionBoxItem(
            suggestionEmailAddress,
            shapeBorder: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
            selectedContactCallbackAction: (contact) {
              setState(() => listEmailAddress.add(contact));
              tagEditorState.selectSuggestion(suggestionEmailAddress);
            },
          ),
        );
      },
    );

    if (widget.hasAddContactButton == true) {
      if (_responsiveUtils.isScreenWithShortestSide(context)) {
        return Container(
          color: Colors.transparent,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              itemTagEditor,
              const SizedBox(height: 16),
              _buildAddRecipientButton(context, maxWidth: double.infinity)
            ],
          ),
        );
      } else {
        return Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Expanded(child: itemTagEditor),
              const SizedBox(width: 12),
              _buildAddRecipientButton(context)
            ],
          ),
        );
      }
    } else {
      return itemTagEditor;
    }
  }

  bool _isDuplicatedRecipient(String inputEmail) {
    if (inputEmail.isEmpty) {
      return false;
    }
    return listEmailAddress
      .map((emailAddress) => emailAddress.email)
      .whereNotNull()
      .contains(inputEmail);
  }

  FutureOr<List<SuggestionEmailAddress>> _findSuggestions(String query) async {
    if (_gapBetweenTagChangedAndFindSuggestion.isActive) {
      return [];
    }

    final processedQuery = query.trim();

    if (processedQuery.isEmpty) {
      return [];
    }

    final teamMailSuggestion = List<SuggestionEmailAddress>.empty(growable: true);
    if (processedQuery.isNotEmpty && widget.onSuggestionCallback != null) {
      final addedEmailAddresses = await widget.onSuggestionCallback!(processedQuery);
      final listSuggestionEmailAddress = addedEmailAddresses
        .map((emailAddress) => _toSuggestionEmailAddress(emailAddress, listEmailAddress))
        .toList();
      teamMailSuggestion.addAll(listSuggestionEmailAddress);
    }

    teamMailSuggestion.addAll(_matchedSuggestionEmailAddress(processedQuery, listEmailAddress));

    return teamMailSuggestion.toSet().toList();
  }

  SuggestionEmailAddress _toSuggestionEmailAddress(
      EmailAddress item,
      List<EmailAddress> addedEmailAddresses
  ) {
    if (addedEmailAddresses.contains(item)) {
      return SuggestionEmailAddress(item, state: SuggestionEmailState.duplicated);
    } else {
      return SuggestionEmailAddress(item);
    }
  }

  Iterable<SuggestionEmailAddress> _matchedSuggestionEmailAddress(
    String query,
    List<EmailAddress> addedEmailAddress
  ) {
    return addedEmailAddress
      .where((addedMail) => addedMail.emailAddress.contains(query))
      .map((emailAddress) => SuggestionEmailAddress(emailAddress, state: SuggestionEmailState.duplicated));
  }

  bool _isValidAllEmailAddress(List<EmailAddress> addedEmailAddress) {
    return addedEmailAddress.every((addedMail) => addedMail.emailAddress.isEmail);
  }

  bool _inputFieldIsEmpty() {
    return widget.controller?.text.isEmpty == true;
  }

  Widget _buildAddRecipientButton(BuildContext context, {double? maxWidth}) {
    return (ButtonBuilder(_imagePaths.icAddIdentity)
      ..key(const Key('button_add_recipient'))
      ..decoration(BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColor.colorTextButton))
      ..paddingIcon(const EdgeInsets.only(right: 8))
      ..iconColor(Colors.white)
      ..maxWidth(maxWidth ?? 167)
      ..size(20)
      ..radiusSplash(12)
      ..padding(const EdgeInsets.symmetric(vertical: 12))
      ..textStyle(const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w500))
      ..onPressActionClick(() {
        if (_isValidAllEmailAddress(listEmailAddress) && _inputFieldIsEmpty()) {
          widget.onAddContactCallback?.call(List.from(listEmailAddress));
          setState(() {
            widget.controller?.clear();
            listEmailAddress.clear();
          });
        } else {
          widget.onExceptionCallback?.call();
        }
      })
      ..text(AppLocalizations.of(context).addRecipientButton, isVertical: false)
    ).build();
  }
}