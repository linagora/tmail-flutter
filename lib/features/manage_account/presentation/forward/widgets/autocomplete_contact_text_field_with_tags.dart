
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/material_text_icon_button.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/suggestion_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/contact_input_tag_item.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/contact_suggestion_box_item.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/manage_account/domain/exceptions/forward_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

typedef OnSuggestionContactCallbackAction = Future<List<EmailAddress>> Function(String query, {int? limit});
typedef OnAddListContactCallbackAction = Function(List<EmailAddress> listEmailAddress);
typedef OnExceptionAddListContactCallbackAction = Function(Exception exception);

class AutocompleteContactTextFieldWithTags extends StatefulWidget {

  final List<EmailAddress> listEmailAddress;
  final TextEditingController? controller;
  final bool? hasAddContactButton;
  final OnSuggestionContactCallbackAction? onSuggestionCallback;
  final OnAddListContactCallbackAction? onAddContactCallback;
  final OnExceptionAddListContactCallbackAction? onExceptionCallback;
  final String internalDomain;
  final int minInputLengthAutocomplete;

  const AutocompleteContactTextFieldWithTags({
    Key? key,
    required this.listEmailAddress,
    required this.internalDomain,
    this.controller,
    this.hasAddContactButton = false,
    this.minInputLengthAutocomplete = AppConfig.defaultMinInputLengthAutocomplete,
    this.onSuggestionCallback,
    this.onAddContactCallback,
    this.onExceptionCallback,
  }) : super(key: key);

  @override
  State<AutocompleteContactTextFieldWithTags> createState() => _AutocompleteContactTextFieldWithTagsState();
}

class _AutocompleteContactTextFieldWithTagsState extends State<AutocompleteContactTextFieldWithTags> with MessageDialogActionMixin {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();
  final GlobalKey<TagsEditorState> keyToEmailTagEditor = GlobalKey<TagsEditorState>();
  final FocusNode _focusNodeKeyboard = FocusNode();

  late List<EmailAddress> listEmailAddress;

  bool lastTagFocused = false;

  @override
  void initState() {
    super.initState();
    listEmailAddress = widget.listEmailAddress;
  }

  @override
  void dispose() {
    _focusNodeKeyboard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemTagEditor = TagEditor<SuggestionEmailAddress>(
      key: keyToEmailTagEditor,
      length: listEmailAddress.length,
      controller: widget.controller,
      focusNodeKeyboard: _focusNodeKeyboard,
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
      tagSpacing: PlatformInfo.isWeb ? 12 : 8,
      autofocus: false,
      minTextFieldWidth: 20,
      debounceDuration: const Duration(milliseconds: 150),
      autoScrollToInput: false,
      suggestionsBoxBackgroundColor: Colors.white,
      suggestionsBoxRadius: 16,
      suggestionsBoxMaxHeight: 350,
      onFocusTagAction: (focused) {
        setState(() {
          lastTagFocused = focused;
        });
      },
      onDeleteTagAction: () {
        if (listEmailAddress.isNotEmpty) {
          setState(() {
            listEmailAddress.removeLast();
          });
        }
      },
      onSelectOptionAction: (item) => _addEmailAddressToInputFieldAction(
        context: context,
        emailAddress: item.emailAddress
      ),
      onSubmitted: (value) => _addEmailAddressToInputFieldAction(
        context: context,
        emailAddress: EmailAddress(null, value),
        isClearInput: true
      ),
      textStyle: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w500),
      inputDecoration: InputDecoration(
        border: InputBorder.none,
        hintText: AppLocalizations.of(context).hintInputAutocompleteContact,
        hintStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColor.colorSettingExplanation,
          fontSize: 16
        )
      ),
      tagBuilder: (context, index) => ContactInputTagItem(
        listEmailAddress[index],
        isLastContact: index == listEmailAddress.length - 1,
        lastTagFocused: lastTagFocused,
        deleteContactCallbackAction: (contact) {
          setState(() => listEmailAddress.remove(contact));
        }
      ),
      onTagChanged: (_) {},
      findSuggestions: (queryString) => _findSuggestions(
        queryString,
        limit: AppConfig.defaultLimitAutocomplete,
      ),
      suggestionItemHeight: ComposerStyle.suggestionItemHeight,
      isLoadMoreOnlyOnce: true,
      isLoadMoreReplaceAllOld: false,
      loadMoreSuggestions: _findSuggestions,
      suggestionBuilder: (context, tagEditorState, suggestionEmailAddress, index, length, highlight, suggestionValid) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ContactSuggestionBoxItem(
            suggestionEmailAddress,
            _imagePaths,
            shapeBorder: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
            selectedContactCallbackAction: (contact) {
              _addEmailAddressToInputFieldAction(
                context: context,
                emailAddress: contact
              );
              tagEditorState.closeSuggestionBox();
              tagEditorState.resetTextField();
            },
          ),
        );
      },
    );

    if (widget.hasAddContactButton == true) {
      return _responsiveUtils.isScreenWithShortestSide(context)
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              itemTagEditor,
              const SizedBox(height: 16),
              _buildAddRecipientButton(context, maxWidth: double.infinity)
            ],
          )
        : Row(
            children: [
              Expanded(child: itemTagEditor),
              const SizedBox(width: 12),
              _buildAddRecipientButton(context)
            ],
          );
    } else {
      return itemTagEditor;
    }
  }

  bool _isDuplicatedRecipient(String inputEmail) {
    log('_AutocompleteContactTextFieldWithTagsState::_isDuplicatedRecipient: inputEmail = $inputEmail');
    if (inputEmail.isEmpty) {
      return false;
    }
    return listEmailAddress
      .map((emailAddress) => emailAddress.email)
      .whereNotNull()
      .contains(inputEmail);
  }

  FutureOr<List<SuggestionEmailAddress>> _findSuggestions(String query, {int? limit}) async {
    final processedQuery = query.trim();

    if (processedQuery.isEmpty) {
      return [];
    }

    final teamMailSuggestion = List<SuggestionEmailAddress>.empty(growable: true);
    if (processedQuery.isNotEmpty
        && processedQuery.length >= widget.minInputLengthAutocomplete
        && widget.onSuggestionCallback != null
    ) {
      final addedEmailAddresses = await widget.onSuggestionCallback!(
        processedQuery,
        limit: limit,
      );
      final listSuggestionEmailAddress = addedEmailAddresses
        .map((emailAddress) => _toSuggestionEmailAddress(emailAddress, listEmailAddress))
        .toList();
      teamMailSuggestion.addAll(listSuggestionEmailAddress);
    }

    teamMailSuggestion.addAll(_matchedSuggestionEmailAddress(processedQuery, listEmailAddress));

    final currentTextOnTextField = widget.controller?.text ?? '';
    if (currentTextOnTextField.isEmpty) {
      return [];
    }

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

  bool _validateListEmailAddressIsValid(List<EmailAddress> listEmailAddress) => listEmailAddress.every(_validateEmailAddressIsValid);

  Widget _buildAddRecipientButton(BuildContext context, {double? maxWidth}) {
    return MaterialTextIconButton(
      key: const Key('button_add_recipient'),
      label: AppLocalizations.of(context).addRecipientButton,
      icon: _imagePaths.icAddIdentity,
      backgroundColor: AppColor.colorTextButton,
      labelColor: Colors.white,
      iconColor: Colors.white,
      minimumSize: Size(maxWidth ?? 167, PlatformInfo.isMobile ? 44 : 54),
      onTap: () => _handleAddRecipientAction(context)
    );
  }

  void _handleAddRecipientAction(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);

    final inputText = widget.controller?.text ?? '';

    if (inputText.isNotEmpty) {
      final emailAddress = EmailAddress(null, inputText);

      if (!_validateEmailAddressIsValid(emailAddress)) {
        widget.onExceptionCallback?.call(RecipientListWithInvalidEmailsException());
        _resetInputText();
        return;
      }

      _validateEmailAddressSameDomain(
        context: context,
        emailAddress: emailAddress,
        confirmAction: () {
          final newListEmailAddress = List<EmailAddress>.from([...listEmailAddress, emailAddress]);

          widget.onAddContactCallback?.call(newListEmailAddress);

          _resetInputText();
          if (listEmailAddress.isNotEmpty) {
            setState(listEmailAddress.clear);
          }
        },
        cancelAction: () {
          if (listEmailAddress.isNotEmpty) {
            widget.onAddContactCallback?.call(listEmailAddress);
            setState(listEmailAddress.clear);
          }
          _resetInputText();
        },
        sameDomainAction: () {
          final newListEmailAddress = List<EmailAddress>.from([...listEmailAddress, emailAddress]);

          widget.onAddContactCallback?.call(newListEmailAddress);

          _resetInputText();
          if (listEmailAddress.isNotEmpty) {
            setState(listEmailAddress.clear);
          }
        },
        duplicatedRecipientAction: () {
          if (listEmailAddress.isNotEmpty) {
            widget.onAddContactCallback?.call(listEmailAddress);
            setState(listEmailAddress.clear);
          }
          _resetInputText();
        }
      );

      _closeSuggestionBox();
      return;
    }

    if (listEmailAddress.isEmpty) {
      widget.onExceptionCallback?.call(RecipientListIsEmptyException());
      return;
    }

    if (!_validateListEmailAddressIsValid(listEmailAddress)) {
      widget.onExceptionCallback?.call(RecipientListWithInvalidEmailsException());
      return;
    }

    widget.onAddContactCallback?.call(List.from(listEmailAddress));

    _resetInputText();
    setState(listEmailAddress.clear);
  }

  bool _validateEmailAddressIsValid(EmailAddress emailAddress) {
    return GetUtils.isEmail(emailAddress.emailAddress)
      || AppUtils.isEmailLocalhost(emailAddress.emailAddress);
  }

  void _validateEmailAddressSameDomain({
    required BuildContext context,
    required EmailAddress emailAddress,
    required VoidCallback? confirmAction,
    required VoidCallback? cancelAction,
    required VoidCallback? sameDomainAction,
    required VoidCallback? duplicatedRecipientAction,
  }) {
    if (_isDuplicatedRecipient(emailAddress.emailAddress)) {
      duplicatedRecipientAction?.call();
      return;
    }

    bool isSameDomain = EmailUtils.isSameDomain(
      emailAddress: emailAddress.emailAddress,
      internalDomain: widget.internalDomain
    );

    if (isSameDomain) {
      sameDomainAction?.call();
    } else {
      _showWarningDialogWithExternalDomain(
        context: context,
        confirmAction: confirmAction,
        cancelAction: cancelAction
      );
    }
  }

  void _closeSuggestionBox() {
    keyToEmailTagEditor.currentState?.closeSuggestionBox();
  }

  void _resetInputText() {
    keyToEmailTagEditor.currentState?.resetTextField();
  }

  void _addEmailAddressToInputFieldAction({
    required BuildContext context,
    required EmailAddress emailAddress,
    bool isClearInput = false
  }) {
    log('_AutocompleteContactTextFieldWithTagsState::_addEmailAddressToInputFieldAction:emailAddress = $emailAddress');
    if (!_validateEmailAddressIsValid(emailAddress)) {
      widget.onExceptionCallback?.call(RecipientListWithInvalidEmailsException());
      if (isClearInput) {
        _resetInputText();
      }
      return;
    }

    _validateEmailAddressSameDomain(
      context: context,
      emailAddress: emailAddress,
      confirmAction: () {
        if (isClearInput) {
          _resetInputText();
        }
        setState(() => listEmailAddress.add(emailAddress));
      },
      cancelAction: () {
        if (isClearInput) {
          _resetInputText();
        }
      },
      sameDomainAction: () {
        if (isClearInput) {
          _resetInputText();
        }
        setState(() => listEmailAddress.add(emailAddress));
      },
      duplicatedRecipientAction: () {
        if (isClearInput) {
          _resetInputText();
        }
      }
    );
  }

  void _showWarningDialogWithExternalDomain({
    required BuildContext context,
    VoidCallback? confirmAction,
    VoidCallback? cancelAction
  }) async {
    await showConfirmDialogAction(
      context,
      AppLocalizations.of(context).doYouWantToProceed,
      AppLocalizations.of(context).yes,
      title: AppConfig.getForwardWarningMessage(context),
      cancelTitle: AppLocalizations.of(context).no,
      alignCenter: true,
      onConfirmAction: confirmAction,
      onCancelAction: cancelAction,
      cancelButtonColor: AppColor.blue700,
      cancelLabelButtonColor: Colors.white,
      actionButtonColor: AppColor.grayBackgroundColor,
      confirmLabelButtonColor: AppColor.steelGray600,
      icon: SvgPicture.asset(
        _imagePaths.icQuotasWarning,
        width: 40,
        height: 40,
        colorFilter: AppColor.colorQuotaError.asFilter(),
      ),
    );
  }
}