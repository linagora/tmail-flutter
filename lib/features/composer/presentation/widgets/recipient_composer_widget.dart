
import 'dart:async';
import 'dart:math';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/mail/mail_address.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/string_convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/mail_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draggable_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/suggestion_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/recipient_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_suggestion_item_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_tag_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

typedef OnSuggestionEmailAddress = Future<List<EmailAddress>> Function(String word, {int? limit});
typedef OnUpdateListEmailAddressAction = void Function(PrefixEmailAddress prefix, List<EmailAddress> newData);
typedef OnAddEmailAddressTypeAction = void Function(PrefixEmailAddress prefix);
typedef OnDeleteEmailAddressTypeAction = void Function(PrefixEmailAddress prefix);
typedef OnShowFullListEmailAddressAction = void Function(PrefixEmailAddress prefix);
typedef OnFocusEmailAddressChangeAction = void Function(PrefixEmailAddress prefix, bool isFocus);
typedef OnRemoveDraggableEmailAddressAction = void Function(DraggableEmailAddress draggableEmailAddress);
typedef OnDeleteTagAction = void Function(EmailAddress emailAddress);
typedef OnEnableAllRecipientsInputAction = void Function(bool isEnabled);

class RecipientComposerWidget extends StatefulWidget {

  final PrefixEmailAddress prefix;
  final List<EmailAddress> listEmailAddress;
  final ImagePaths imagePaths;
  final double maxWidth;
  final ExpandMode expandMode;
  final PrefixRecipientState fromState;
  final PrefixRecipientState ccState;
  final PrefixRecipientState bccState;
  final PrefixRecipientState replyToState;
  final bool? isInitial;
  final FocusNode? focusNode;
  final FocusNode? focusNodeKeyboard;
  final GlobalKey? keyTagEditor;
  final FocusNode? nextFocusNode;
  final TextEditingController? controller;
  final OnUpdateListEmailAddressAction? onUpdateListEmailAddressAction;
  final OnSuggestionEmailAddress? onSuggestionEmailAddress;
  final OnAddEmailAddressTypeAction? onAddEmailAddressTypeAction;
  final OnDeleteEmailAddressTypeAction? onDeleteEmailAddressTypeAction;
  final OnShowFullListEmailAddressAction? onShowFullListEmailAddressAction;
  final OnFocusEmailAddressChangeAction? onFocusEmailAddressChangeAction;
  final OnRemoveDraggableEmailAddressAction? onRemoveDraggableEmailAddressAction;
  final VoidCallback? onFocusNextAddressAction;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final OnEnableAllRecipientsInputAction? onEnableAllRecipientsInputAction;
  final bool isTestingForWeb;
  final int minInputLengthAutocomplete;

  const RecipientComposerWidget({
    super.key,
    required this.prefix,
    required this.listEmailAddress,
    required this.imagePaths,
    required this.maxWidth,
    this.minInputLengthAutocomplete = AppConfig.defaultMinInputLengthAutocomplete,
    @visibleForTesting this.isTestingForWeb = false,
    this.ccState = PrefixRecipientState.disabled,
    this.bccState = PrefixRecipientState.disabled,
    this.replyToState = PrefixRecipientState.disabled,
    this.fromState = PrefixRecipientState.disabled,
    this.isInitial,
    this.controller,
    this.focusNode,
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
    this.onRemoveDraggableEmailAddressAction,
    this.onEnableAllRecipientsInputAction,
    this.focusNodeKeyboard,
  });

  @override
  State<RecipientComposerWidget> createState() => _RecipientComposerWidgetState();
}

class _RecipientComposerWidgetState extends State<RecipientComposerWidget> {

  Timer? _gapBetweenTagChangedAndFindSuggestion;
  bool _lastTagFocused = false;
  bool _isDragging = false;
  late List<EmailAddress> _currentListEmailAddress;

  @override
  void initState() {
    super.initState();
    _currentListEmailAddress = widget.listEmailAddress;
  }

  @override
  void didUpdateWidget(covariant RecipientComposerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listEmailAddress != widget.listEmailAddress) {
      _currentListEmailAddress = widget.listEmailAddress;
    }
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
              key: Key('prefix_${widget.prefix.name}_recipient_composer_widget'),
              style: RecipientComposerWidgetStyle.prefixLabelTextStyle,
            ),
          ),
          const SizedBox(width: RecipientComposerWidgetStyle.space),
          Expanded(
            child: FocusScope(
              onFocusChange: (focus) => widget.onFocusEmailAddressChangeAction?.call(widget.prefix, focus),
              onKeyEvent: PlatformInfo.isWeb ? _recipientInputOnKeyListener : null,
              child: StatefulBuilder(
                builder: (context, stateSetter) {
                  if (PlatformInfo.isWeb || widget.isTestingForWeb) {
                    return DragTarget<DraggableEmailAddress>(
                      builder: (context, candidateData, rejectedData) {
                        return TagEditor<SuggestionEmailAddress>(
                          key: widget.keyTagEditor,
                          length: _collapsedListEmailAddress.length,
                          controller: widget.controller,
                          focusNode: widget.focusNode,
                          enableBorder: _isDragging,
                          focusNodeKeyboard: widget.focusNodeKeyboard,
                          borderRadius: RecipientComposerWidgetStyle.enableBorderRadius,
                          enableBorderColor: RecipientComposerWidgetStyle.enableBorderColor,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          debounceDuration: RecipientComposerWidgetStyle.suggestionDebounceDuration,
                          tagSpacing: RecipientComposerWidgetStyle.tagSpacing,
                          autofocus: widget.prefix != PrefixEmailAddress.to && _currentListEmailAddress.isEmpty,
                          minTextFieldWidth: RecipientComposerWidgetStyle.minTextFieldWidth,
                          resetTextOnSubmitted: true,
                          autoScrollToInput: false,
                          autoHideTextInputField: true,
                          cursorColor: RecipientComposerWidgetStyle.cursorColor,
                          suggestionsBoxElevation: RecipientComposerWidgetStyle.suggestionsBoxElevation,
                          suggestionsBoxBackgroundColor: RecipientComposerWidgetStyle.suggestionsBoxBackgroundColor,
                          suggestionsBoxRadius: RecipientComposerWidgetStyle.suggestionsBoxRadius,
                          suggestionsBoxMaxHeight: RecipientComposerWidgetStyle.suggestionsBoxMaxHeight,
                          suggestionItemHeight: RecipientComposerWidgetStyle.suggestionBoxItemHeight,
                          suggestionBoxWidth: _getSuggestionBoxWidth(widget.maxWidth),
                          textStyle: RecipientComposerWidgetStyle.inputTextStyle,
                          onFocusTagAction: (focused) => _handleFocusTagAction.call(focused, stateSetter),
                          onDeleteTagAction: () => _handleDeleteLatestTagAction.call(stateSetter),
                          onSelectOptionAction: (item) => _handleSelectOptionAction.call(item, stateSetter),
                          onSubmitted: (value) => _handleSubmitTagAction.call(value, stateSetter),
                          onTapOutside: (_) {},
                          onFocusTextInput: () {
                            if (_isCollapse) {
                              widget.onShowFullListEmailAddressAction?.call(widget.prefix);
                            }
                          },
                          inputDecoration: const InputDecoration(border: InputBorder.none),
                          tagBuilder: (context, index) {
                            final currentEmailAddress = _currentListEmailAddress[index];
                            final isLatestEmail = currentEmailAddress == _currentListEmailAddress.last;

                            return RecipientTagItemWidget(
                              index: index,
                              imagePaths: widget.imagePaths,
                              prefix: widget.prefix,
                              currentEmailAddress: currentEmailAddress,
                              currentListEmailAddress: _currentListEmailAddress,
                              collapsedListEmailAddress: _collapsedListEmailAddress,
                              isLatestEmail: isLatestEmail,
                              isCollapsed: _isCollapse,
                              isLatestTagFocused: _lastTagFocused,
                              maxWidth: widget.maxWidth,
                              onDeleteTagAction: (emailAddress) => _handleDeleteTagAction.call(emailAddress, stateSetter),
                              onShowFullAction: widget.onShowFullListEmailAddressAction,
                            );
                          },
                          onTagChanged: (value) => _handleOnTagChangeAction.call(value, stateSetter),
                          findSuggestions: (queryString) => _findSuggestions(
                            queryString,
                            limit: AppConfig.defaultLimitAutocomplete,
                          ),
                          isLoadMoreOnlyOnce: true,
                          isLoadMoreReplaceAllOld: false,
                          loadMoreSuggestions: _findSuggestions,
                          useDefaultHighlight: false,
                          suggestionBuilder: (context, tagEditorState, suggestionEmailAddress, index, length, highlight, suggestionValid) {
                            return RecipientSuggestionItemWidget(
                              imagePaths: widget.imagePaths,
                              suggestionState: suggestionEmailAddress.state,
                              emailAddress: _subAddressingValidatedEmailAddress(suggestionEmailAddress.emailAddress),
                              suggestionValid: suggestionValid,
                              highlight: highlight,
                              onSelectedAction: (emailAddress) {
                                stateSetter(() => _currentListEmailAddress.add(emailAddress));
                                _updateListEmailAddressAction();
                                tagEditorState.resetTextField();
                                tagEditorState.closeSuggestionBox();
                              },
                            );
                          },
                        );
                      },
                      onAcceptWithDetails: (draggableEmailAddress) => _handleAcceptDraggableEmailAddressAction(draggableEmailAddress.data, stateSetter),
                      onLeave: (draggableEmailAddress) {
                        if (_isDragging) {
                          stateSetter(() => _isDragging = false);
                        }
                      },
                      onMove: (details) {
                        if (!_isDragging) {
                          stateSetter(() => _isDragging = true);
                        }
                      },
                    );
                  } else {
                    return TagEditor<SuggestionEmailAddress>(
                      key: widget.keyTagEditor,
                      length: _collapsedListEmailAddress.length,
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      focusNodeKeyboard: widget.focusNodeKeyboard,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      debounceDuration: RecipientComposerWidgetStyle.suggestionDebounceDuration,
                      tagSpacing: RecipientComposerWidgetStyle.tagSpacing,
                      minTextFieldWidth: RecipientComposerWidgetStyle.minTextFieldWidth,
                      resetTextOnSubmitted: true,
                      autoScrollToInput: false,
                      autoHideTextInputField: true,
                      cursorColor: RecipientComposerWidgetStyle.cursorColor,
                      suggestionsBoxElevation: RecipientComposerWidgetStyle.suggestionsBoxElevation,
                      suggestionsBoxBackgroundColor: RecipientComposerWidgetStyle.suggestionsBoxBackgroundColor,
                      suggestionsBoxRadius: RecipientComposerWidgetStyle.suggestionsBoxRadius,
                      suggestionsBoxMaxHeight: RecipientComposerWidgetStyle.suggestionsBoxMaxHeight,
                      suggestionItemHeight: RecipientComposerWidgetStyle.suggestionBoxItemHeight,
                      suggestionBoxWidth: _getSuggestionBoxWidth(widget.maxWidth),
                      textStyle: RecipientComposerWidgetStyle.inputTextStyle,
                      onFocusTagAction: (focused) => _handleFocusTagAction.call(focused, stateSetter),
                      onDeleteTagAction: () => _handleDeleteLatestTagAction.call(stateSetter),
                      onSelectOptionAction: (item) => _handleSelectOptionAction.call(item, stateSetter),
                      onSubmitted: (value) => _handleSubmitTagAction.call(value, stateSetter),
                      onTapOutside: (_) {},
                      onFocusTextInput: () {
                        if (_isCollapse) {
                          widget.onShowFullListEmailAddressAction?.call(widget.prefix);
                        }
                      },
                      inputDecoration: const InputDecoration(border: InputBorder.none),
                      tagBuilder: (context, index) {
                        final currentEmailAddress = _currentListEmailAddress[index];
                        final isLatestEmail = currentEmailAddress == _currentListEmailAddress.last;

                        return RecipientTagItemWidget(
                          index: index,
                          imagePaths: widget.imagePaths,
                          prefix: widget.prefix,
                          currentEmailAddress: currentEmailAddress,
                          currentListEmailAddress: _currentListEmailAddress,
                          collapsedListEmailAddress: _collapsedListEmailAddress,
                          isLatestEmail: isLatestEmail,
                          isCollapsed: _isCollapse,
                          isLatestTagFocused: _lastTagFocused,
                          maxWidth: widget.maxWidth,
                          onDeleteTagAction: (emailAddress) => _handleDeleteTagAction.call(emailAddress, stateSetter),
                          onShowFullAction: widget.onShowFullListEmailAddressAction,
                        );
                      },
                      onTagChanged: (value) => _handleOnTagChangeAction.call(value, stateSetter),
                      findSuggestions: (queryString) => _findSuggestions(
                        queryString,
                        limit: AppConfig.defaultLimitAutocomplete,
                      ),
                      isLoadMoreOnlyOnce: true,
                      isLoadMoreReplaceAllOld: false,
                      loadMoreSuggestions: _findSuggestions,
                      useDefaultHighlight: false,
                      suggestionBuilder: (context, tagEditorState, suggestionEmailAddress, index, length, highlight, suggestionValid) {
                        return RecipientSuggestionItemWidget(
                          imagePaths: widget.imagePaths,
                          suggestionState: suggestionEmailAddress.state,
                          emailAddress: _subAddressingValidatedEmailAddress(suggestionEmailAddress.emailAddress),
                          suggestionValid: suggestionValid,
                          highlight: highlight,
                          onSelectedAction: (emailAddress) {
                            stateSetter(() => _currentListEmailAddress.add(emailAddress));
                            _updateListEmailAddressAction();
                            tagEditorState.resetTextField();
                            tagEditorState.closeSuggestionBox();
                          },
                        );
                      },
                    );
                  }
                },
              )
            )
          ),
          const SizedBox(width: RecipientComposerWidgetStyle.space),
          if (widget.prefix == PrefixEmailAddress.to)
            if (PlatformInfo.isWeb || widget.isTestingForWeb)
              ...[
                if (widget.fromState == PrefixRecipientState.disabled)
                  TMailButtonWidget.fromText(
                    key: Key('prefix_${widget.prefix.name}_recipient_from_button'),
                    text: AppLocalizations.of(context).from_email_address_prefix,
                    textStyle: RecipientComposerWidgetStyle.prefixButtonTextStyle,
                    backgroundColor: Colors.transparent,
                    padding: RecipientComposerWidgetStyle.prefixButtonPadding,
                    margin: RecipientComposerWidgetStyle.recipientMargin,
                    onTapActionCallback: () => widget.onAddEmailAddressTypeAction?.call(PrefixEmailAddress.from),
                  ),
                if (widget.ccState == PrefixRecipientState.disabled)
                  TMailButtonWidget.fromText(
                    key: Key('prefix_${widget.prefix.name}_recipient_cc_button'),
                    text: AppLocalizations.of(context).cc_email_address_prefix,
                    textStyle: RecipientComposerWidgetStyle.prefixButtonTextStyle,
                    backgroundColor: Colors.transparent,
                    padding: RecipientComposerWidgetStyle.prefixButtonPadding,
                    margin: RecipientComposerWidgetStyle.recipientMargin,
                    onTapActionCallback: () => widget.onAddEmailAddressTypeAction?.call(PrefixEmailAddress.cc),
                  ),
                if (widget.bccState == PrefixRecipientState.disabled)
                  TMailButtonWidget.fromText(
                    key: Key('prefix_${widget.prefix.name}_recipient_bcc_button'),
                    text: AppLocalizations.of(context).bcc_email_address_prefix,
                    textStyle: RecipientComposerWidgetStyle.prefixButtonTextStyle,
                    backgroundColor: Colors.transparent,
                    padding: RecipientComposerWidgetStyle.prefixButtonPadding,
                    margin: RecipientComposerWidgetStyle.recipientMargin,
                    onTapActionCallback: () => widget.onAddEmailAddressTypeAction?.call(PrefixEmailAddress.bcc),
                  ),
                if (widget.replyToState == PrefixRecipientState.disabled)
                  TMailButtonWidget.fromText(
                    key: Key('prefix_${widget.prefix.name}_recipient_reply_to_button'),
                    text: AppLocalizations.of(context).reply_to_email_address_prefix,
                    textStyle: RecipientComposerWidgetStyle.prefixButtonTextStyle,
                    backgroundColor: Colors.transparent,
                    padding: RecipientComposerWidgetStyle.prefixButtonPadding,
                    margin: RecipientComposerWidgetStyle.recipientMargin,
                    onTapActionCallback: () => widget.onAddEmailAddressTypeAction?.call(PrefixEmailAddress.replyTo),
                  ),
              ]
            else if (PlatformInfo.isMobile)
              TMailButtonWidget.fromIcon(
                key: Key('prefix_${widget.prefix.name}_recipient_expand_button'),
                icon: _isAllRecipientInputEnabled
                  ? widget.imagePaths.icChevronUp
                  : widget.imagePaths.icChevronDownOutline,
                backgroundColor: Colors.transparent,
                iconSize: 24,
                padding: const EdgeInsets.all(5),
                iconColor: AppColor.colorLabelComposer,
                margin: RecipientComposerWidgetStyle.enableRecipientButtonMargin,
                onTapActionCallback: () => widget.onEnableAllRecipientsInputAction?.call(_isAllRecipientInputEnabled),
              )
          else if (PlatformInfo.isWeb || widget.isTestingForWeb)
            TMailButtonWidget.fromIcon(
              icon: widget.imagePaths.icClose,
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

  KeyEventResult _recipientInputOnKeyListener(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
      widget.nextFocusNode?.requestFocus();
      widget.onFocusNextAddressAction?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  bool get _isCollapse => _currentListEmailAddress.length > 1 && widget.expandMode == ExpandMode.COLLAPSE;

  bool get _isAllRecipientInputEnabled => widget.fromState == PrefixRecipientState.enabled
    && widget.ccState == PrefixRecipientState.enabled
    && widget.bccState == PrefixRecipientState.enabled
    && widget.replyToState == PrefixRecipientState.enabled;

  List<EmailAddress> get _collapsedListEmailAddress => _isCollapse
    ? _currentListEmailAddress.sublist(0, 1)
    : _currentListEmailAddress;

  FutureOr<List<SuggestionEmailAddress>> _findSuggestions(String query, {int? limit}) async {
    if (_gapBetweenTagChangedAndFindSuggestion?.isActive ?? false) {
      return [];
    }

    final processedQuery = query.trim();
    if (processedQuery.isEmpty) {
      return [];
    }

    final tmailSuggestion = List<SuggestionEmailAddress>.empty(growable: true);
    if (processedQuery.length >= widget.minInputLengthAutocomplete &&
        widget.onSuggestionEmailAddress != null) {
      final listEmailAddress = await widget.onSuggestionEmailAddress!(
        processedQuery,
        limit: limit,
      );
      final listSuggestionEmailAddress = listEmailAddress
        .map((emailAddress) => _toSuggestionEmailAddress(
          emailAddress,
          _currentListEmailAddress));
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
    if (inputEmail.trim().isEmpty) return false;

    return _currentListEmailAddress
      .any((emailAddress) => emailAddress.email?.trim() == inputEmail.trim());
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
    log('_RecipientComposerWidgetState::_handleGapBetweenTagChangedAndFindSuggestion:Timeout');
  }

  void _updateListEmailAddressAction() {
    widget.onUpdateListEmailAddressAction?.call(
      widget.prefix,
      _currentListEmailAddress
    );
  }

  void _handleFocusTagAction(bool focused, StateSetter stateSetter) {
    stateSetter(() => _lastTagFocused = focused);
  }

  void _handleDeleteLatestTagAction(StateSetter stateSetter) {
    if (_currentListEmailAddress.isNotEmpty) {
      stateSetter(_currentListEmailAddress.removeLast);
      _updateListEmailAddressAction();
    }
  }

  void _handleDeleteTagAction(EmailAddress emailAddress, StateSetter stateSetter) {
    if (_currentListEmailAddress.isNotEmpty) {
      stateSetter(() => _currentListEmailAddress.remove(emailAddress));
      _updateListEmailAddressAction();
    }
  }

  void _handleSelectOptionAction(
    SuggestionEmailAddress suggestionEmailAddress,
    StateSetter stateSetter
  ) => _onEmailAddressReceived(
    suggestionEmailAddress.emailAddress.emailAddress,
    stateSetter,
  );

  void _handleSubmitTagAction(
    String value,
    StateSetter stateSetter
  ) => _createMailTag(value, stateSetter);

  void _createMailTag(String value, StateSetter stateSetter) {
    final listString = StringConvert.extractStrings(value.trim()).toSet();

    if (listString.isEmpty && !_isDuplicatedRecipient(value)) {
      _onEmailAddressReceived(value, stateSetter);
    } else if (listString.isNotEmpty) {
      final listStringNotExist = listString
        .where((text) => !_isDuplicatedRecipient(text))
        .toList();

      if (listStringNotExist.isNotEmpty) {
        final listAddress = listStringNotExist
          .map((text) => EmailAddress(null, text))
          .toList();
        
        stateSetter(() => _currentListEmailAddress.addAll(listAddress));
        _updateListEmailAddressAction();
      }
    }
  }

  void _handleOnTagChangeAction(
    String value,
    StateSetter stateSetter
  ) {
    _onEmailAddressReceived(value, stateSetter);
    _gapBetweenTagChangedAndFindSuggestion = Timer(
      const Duration(seconds: 1),
      _handleGapBetweenTagChangedAndFindSuggestion
    );
  }

  void _handleAcceptDraggableEmailAddressAction(
    DraggableEmailAddress draggableEmailAddress,
    StateSetter stateSetter
  ) {
    log('_RecipientComposerWidgetState::_handleAcceptDraggableEmailAddressAction: $draggableEmailAddress');
    if (draggableEmailAddress.prefix != widget.prefix) {
      if (!_currentListEmailAddress.contains(draggableEmailAddress.emailAddress)) {
        stateSetter(() {
          _currentListEmailAddress.add(draggableEmailAddress.emailAddress);
          _isDragging = false;
        });
        _updateListEmailAddressAction();
      } else {
        if (_isDragging) {
          stateSetter(() => _isDragging = false);
        }
      }
      widget.onRemoveDraggableEmailAddressAction?.call(draggableEmailAddress);
    } else {
      if (_isDragging) {
        stateSetter(() => _isDragging = false);
      }
    }
  }

  double? _getSuggestionBoxWidth(double maxWidth) {
    if (maxWidth < ResponsiveUtils.minTabletWidth) {
      final newWidth = min(maxWidth, RecipientComposerWidgetStyle.suggestionBoxWidth);
      return newWidth;
    } else {
      return null;
    }
  }

  void _onEmailAddressReceived(String input, StateSetter stateSetter) {
    final emailAddressRecord = _generateEmailAddressFromString(input);
    if (!_isDuplicatedRecipient(emailAddressRecord.$1)) {
      stateSetter(() => _currentListEmailAddress.add(emailAddressRecord.$2));
      _updateListEmailAddressAction();
    }
  }

  EmailAddress _subAddressingValidatedEmailAddress(EmailAddress emailAddress) {
    try {
      final mailAddress = MailAddress.validateAddress(emailAddress.emailAddress);
      return mailAddress.asEmailAddress();
    } catch (e) {
      return emailAddress;
    }
  }

  (String email, EmailAddress emailAddress) _generateEmailAddressFromString(String input) {
    try {
      final mailAddress = MailAddress.validateAddress(input);
      return (mailAddress.asEncodedString(), mailAddress.asEmailAddress());
    } catch (e) {
      return (input, EmailAddress(null, input));
    }
  }
}