
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/recipient_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_suggestion_item_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_tag_item_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/suggestion_email_address.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_constants.dart';

typedef OnSuggestionEmailAddress = Future<List<EmailAddress>> Function(String word);
typedef OnUpdateListEmailAddressAction = void Function(PrefixEmailAddress prefix, List<EmailAddress> newData);
typedef OnAddEmailAddressTypeAction = void Function(PrefixEmailAddress prefix);
typedef OnDeleteEmailAddressTypeAction = void Function(PrefixEmailAddress prefix);
typedef OnShowFullListEmailAddressAction = void Function(PrefixEmailAddress prefix);
typedef OnFocusEmailAddressChangeAction = void Function(PrefixEmailAddress prefix, bool isFocus);

class RecipientComposerWidget extends StatefulWidget {

  final PrefixEmailAddress prefix;
  final List<EmailAddress> listEmailAddress;
  final ExpandMode expandMode;
  final PrefixRecipientState ccState;
  final PrefixRecipientState bccState;
  final bool? isInitial;
  final FocusNode? focusNode;
  final bool autoDisposeFocusNode;
  final GlobalKey? keyTagEditor;
  final FocusNode? nextFocusNode;
  final TextEditingController? controller;
  final OnUpdateListEmailAddressAction? onUpdateListEmailAddressAction;
  final OnSuggestionEmailAddress? onSuggestionEmailAddress;
  final OnAddEmailAddressTypeAction? onAddEmailAddressTypeAction;
  final OnDeleteEmailAddressTypeAction? onDeleteEmailAddressTypeAction;
  final OnShowFullListEmailAddressAction? onShowFullListEmailAddressAction;
  final OnFocusEmailAddressChangeAction? onFocusEmailAddressChangeAction;
  final VoidCallback? onFocusNextAddressAction;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const RecipientComposerWidget({
    super.key,
    required this.prefix,
    required this.listEmailAddress,
    this.ccState = PrefixRecipientState.disabled,
    this.bccState = PrefixRecipientState.disabled,
    this.isInitial,
    this.controller,
    this.focusNode,
    this.autoDisposeFocusNode = true,
    this.expandMode = ExpandMode.EXPAND,
    this.keyTagEditor,
    this.nextFocusNode,
    this.padding,
    this.margin,
    this.onUpdateListEmailAddressAction,
    this.onSuggestionEmailAddress,
    this.onAddEmailAddressTypeAction,
    this.onDeleteEmailAddressTypeAction,
    this.onShowFullListEmailAddressAction,
    this.onFocusEmailAddressChangeAction,
    this.onFocusNextAddressAction,
  });

  @override
  State<RecipientComposerWidget> createState() => _RecipientComposerWidgetState();
}

class _RecipientComposerWidgetState extends State<RecipientComposerWidget> {

  Timer? _gapBetweenTagChangedAndFindSuggestion;
  bool _lastTagFocused = false;
  late List<EmailAddress> _currentListEmailAddress;

  final _imagePaths = Get.find<ImagePaths>();

  @override
  void initState() {
    super.initState();
    _currentListEmailAddress = widget.listEmailAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: RecipientComposerWidgetStyle.borderColor,
            width: 1
          )
        )
      ),
      padding: widget.padding,
      margin: widget.margin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: RecipientComposerWidgetStyle.labelMargin,
            child: Text(
              '${widget.prefix.asName(context)}:',
              style: RecipientComposerWidgetStyle.labelTextStyle
            ),
          ),
          const SizedBox(width: RecipientComposerWidgetStyle.space),
          Expanded(
            child: FocusScope(
              child: Focus(
                onFocusChange: (focus) => widget.onFocusEmailAddressChangeAction?.call(widget.prefix, focus),
                onKey: (focusNode, event) {
                  if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
                    widget.nextFocusNode?.requestFocus();
                    widget.onFocusNextAddressAction?.call();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: TagEditor<SuggestionEmailAddress>(
                  key: widget.keyTagEditor,
                  length: _collapsedListEmailAddress.length,
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  autoDisposeFocusNode: widget.autoDisposeFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  debounceDuration: const Duration(milliseconds: 150),
                  hasAddButton: false,
                  tagSpacing: 8,
                  autofocus: widget.prefix != PrefixEmailAddress.to && _currentListEmailAddress.isEmpty,
                  minTextFieldWidth: 20,
                  resetTextOnSubmitted: true,
                  suggestionsBoxElevation: 20.0,
                  suggestionsBoxBackgroundColor: Colors.white,
                  suggestionsBoxRadius: 20,
                  suggestionsBoxMaxHeight: 350,
                  textStyle: RecipientComposerWidgetStyle.inputTextStyle,
                  onFocusTagAction: (focused) {
                    setState(() {
                      _lastTagFocused = focused;
                    });
                  },
                  onDeleteTagAction: () {
                    if (_currentListEmailAddress.isNotEmpty) {
                      setState(_currentListEmailAddress.removeLast);
                      widget.onUpdateListEmailAddressAction?.call(widget.prefix, _currentListEmailAddress);
                    }
                  },
                  onSelectOptionAction: (item) {
                    if (!_isDuplicatedRecipient(item.emailAddress.emailAddress)) {
                      setState(() => _currentListEmailAddress.add(item.emailAddress));
                      widget.onUpdateListEmailAddressAction?.call(widget.prefix, _currentListEmailAddress);
                    }
                  },
                  onSubmitted: (value) {
                    final textTrim = value.trim();
                    if (!_isDuplicatedRecipient(textTrim)) {
                      setState(() => _currentListEmailAddress.add(EmailAddress(null, textTrim)));
                      widget.onUpdateListEmailAddressAction?.call(widget.prefix, _currentListEmailAddress);
                    }
                  },
                  inputDecoration: const InputDecoration(border: InputBorder.none),
                  tagBuilder: (context, index) {
                    final currentEmailAddress = _currentListEmailAddress[index];
                    final isLatestEmail = currentEmailAddress == _currentListEmailAddress.last;

                    return RecipientTagItemWidget(
                      prefix: widget.prefix,
                      currentEmailAddress: currentEmailAddress,
                      currentListEmailAddress: _currentListEmailAddress,
                      collapsedListEmailAddress: _collapsedListEmailAddress,
                      isLatestEmail: isLatestEmail,
                      isCollapsed: _isCollapse,
                      isLatestTagFocused: _lastTagFocused,
                      onDeleteTagAction: () {
                        setState(() => _currentListEmailAddress.removeAt(index));
                        widget.onUpdateListEmailAddressAction?.call(widget.prefix, _currentListEmailAddress);
                      },
                      onShowFullAction: widget.onShowFullListEmailAddressAction,
                    );
                  },
                  onTagChanged: (value) {
                    final textTrim = value.trim();
                    if (!_isDuplicatedRecipient(textTrim)) {
                      setState(() => _currentListEmailAddress.add(EmailAddress(null, textTrim)));
                      widget.onUpdateListEmailAddressAction?.call(widget.prefix, _currentListEmailAddress);
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
                    return RecipientSuggestionItemWidget(
                      suggestionState: suggestionEmailAddress.state,
                      emailAddress: suggestionEmailAddress.emailAddress,
                      suggestionValid: suggestionValid,
                      highlight: highlight,
                      onSelectedAction: (emailAddress) {
                        setState(() => _currentListEmailAddress.add(emailAddress));
                        widget.onUpdateListEmailAddressAction?.call(widget.prefix, _currentListEmailAddress);
                        tagEditorState.resetTextField();
                        tagEditorState.closeSuggestionBox();
                      },
                    );
                  },
                )
              )
            )
          ),
          const SizedBox(width: RecipientComposerWidgetStyle.space),
          if (widget.prefix == PrefixEmailAddress.to && widget.ccState == PrefixRecipientState.disabled)
            TMailButtonWidget.fromText(
              text: AppLocalizations.of(context).cc_email_address_prefix,
              textStyle: RecipientComposerWidgetStyle.prefixButtonTextStyle,
              backgroundColor: Colors.transparent,
              padding: RecipientComposerWidgetStyle.prefixButtonPadding,
              margin: RecipientComposerWidgetStyle.recipientMargin,
              onTapActionCallback: () => widget.onAddEmailAddressTypeAction?.call(PrefixEmailAddress.cc),
            ),
          if (widget.prefix == PrefixEmailAddress.to && widget.bccState == PrefixRecipientState.disabled)
            TMailButtonWidget.fromText(
              text: AppLocalizations.of(context).bcc_email_address_prefix,
              textStyle: RecipientComposerWidgetStyle.prefixButtonTextStyle,
              backgroundColor: Colors.transparent,
              padding: RecipientComposerWidgetStyle.prefixButtonPadding,
              margin: RecipientComposerWidgetStyle.recipientMargin,
              onTapActionCallback: () => widget.onAddEmailAddressTypeAction?.call(PrefixEmailAddress.bcc),
            ),
          if (widget.prefix != PrefixEmailAddress.to)
            TMailButtonWidget.fromIcon(
              icon: _imagePaths.icClose,
              backgroundColor: Colors.transparent,
              iconColor: RecipientComposerWidgetStyle.deleteRecipientFieldIconColor,
              iconSize: RecipientComposerWidgetStyle.deleteRecipientFieldIconSize,
              padding: RecipientComposerWidgetStyle.deleteRecipientFieldIconPadding,
              margin: RecipientComposerWidgetStyle.recipientMargin,
              onTapActionCallback: () => widget.onDeleteEmailAddressTypeAction?.call(widget.prefix),
            )
        ]
      ),
    );
  }

  bool get _isCollapse => _currentListEmailAddress.length > 1 && widget.expandMode == ExpandMode.COLLAPSE;

  List<EmailAddress> get _collapsedListEmailAddress => _isCollapse
    ? _currentListEmailAddress.sublist(0, 1)
    : _currentListEmailAddress;

  FutureOr<List<SuggestionEmailAddress>> _findSuggestions(String query) async {
    if (_gapBetweenTagChangedAndFindSuggestion?.isActive ?? false) {
      return [];
    }

    final processedQuery = query.trim();
    if (processedQuery.isEmpty) {
      return [];
    }

    final tmailSuggestion = List<SuggestionEmailAddress>.empty(growable: true);
    if (processedQuery.length >= AppConstants.limitCharToStartSearch &&
        widget.onSuggestionEmailAddress != null) {
      final listEmailAddress = await widget.onSuggestionEmailAddress!(processedQuery);
      final listSuggestionEmailAddress =  listEmailAddress.map((emailAddress) => _toSuggestionEmailAddress(emailAddress, _currentListEmailAddress));
      tmailSuggestion.addAll(listSuggestionEmailAddress);
    }

    tmailSuggestion.addAll(_matchedSuggestionEmailAddress(processedQuery, _currentListEmailAddress));

    final currentTextOnTextField = widget.controller?.text ?? '';
    if (currentTextOnTextField.isEmpty) {
      return [];
    }

    return tmailSuggestion.toSet().toList();
  }

  bool _isDuplicatedRecipient(String inputEmail) {
    if (inputEmail.isEmpty) {
      return false;
    }
    return _currentListEmailAddress
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
    return addedEmailAddress
      .where((addedMail) => addedMail.emailAddress.contains(query))
      .map((emailAddress) => SuggestionEmailAddress(
        emailAddress,
        state: SuggestionEmailState.duplicated
      ));
  }

  void _handleGapBetweenTagChangedAndFindSuggestion() {
    log('EmailAddressInputBuilder::_handleGapBetweenTagChangedAndFindSuggestion(): Timeout');
  }
}