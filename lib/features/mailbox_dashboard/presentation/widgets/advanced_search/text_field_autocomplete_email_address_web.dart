import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/advanced_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/suggesstion_email_address.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/advanced_search_input_form_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/text_field_autocomplete_email_address_web_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/autocomplete_suggestion_item_widget_web.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/autocomplete_tag_item_widget_web.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

typedef OnSuggestionEmailAddress = Future<List<EmailAddress>> Function(String word);
typedef OnUpdateListEmailAddressAction = void Function(AdvancedSearchFilterField field, List<EmailAddress> newData);
typedef OnDeleteEmailAddressTypeAction = void Function(AdvancedSearchFilterField field);
typedef OnShowFullListEmailAddressAction = void Function(AdvancedSearchFilterField field);
typedef OnDeleteTagAction = void Function(EmailAddress emailAddress);

class TextFieldAutocompleteEmailAddressWeb extends StatefulWidget {

  final AdvancedSearchFilterField field;
  final List<EmailAddress> listEmailAddress;
  final UserName? userName;
  final ExpandMode expandMode;
  final FocusNode? focusNode;
  final GlobalKey? keyTagEditor;
  final FocusNode? nextFocusNode;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final OnSuggestionEmailAddress? onSuggestionEmailAddress;
  final OnDeleteTagAction? onDeleteTag;
  final OnUpdateListEmailAddressAction? onUpdateListEmailAddressAction;
  final OnDeleteEmailAddressTypeAction? onDeleteEmailAddressTypeAction;
  final OnShowFullListEmailAddressAction? onShowFullListEmailAddressAction;
  final TextEditingController? controller;
  final VoidCallback? onSearchAction;

  const TextFieldAutocompleteEmailAddressWeb({
    Key? key,
    required this.field,
    required this.listEmailAddress,
    this.userName,
    this.expandMode = ExpandMode.EXPAND,
    this.focusNode,
    this.keyTagEditor,
    this.nextFocusNode,
    this.padding,
    this.margin,
    this.onSuggestionEmailAddress,
    this.onDeleteTag,
    this.onUpdateListEmailAddressAction,
    this.onDeleteEmailAddressTypeAction,
    this.onShowFullListEmailAddressAction,
    this.controller,
    this.onSearchAction,
  }) : super(key: key);

  @override
  State<TextFieldAutocompleteEmailAddressWeb> createState() => _TextFieldAutocompleteEmailAddressWebState();
}

class _TextFieldAutocompleteEmailAddressWebState extends State<TextFieldAutocompleteEmailAddressWeb> {
  bool _lastTagFocused = false;
  late List<EmailAddress> _currentListEmailAddress;
  Timer? _gapBetweenTagChangedAndFindSuggestion;

  @override
  void initState() {
    super.initState();
    _currentListEmailAddress = widget.listEmailAddress;
  }

  @override
  void didUpdateWidget(covariant TextFieldAutocompleteEmailAddressWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listEmailAddress != oldWidget.listEmailAddress) {
      _currentListEmailAddress = widget.listEmailAddress;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: TextFieldAutoCompleteEmailAddressWebStyles.padding,
      child: LayoutBuilder(
        builder: ((context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: TextFieldAutoCompleteEmailAddressWebStyles.fieldTitleWidth,
                child: Text(
                  widget.field.getTitle(context),
                  style: TextFieldAutoCompleteEmailAddressWebStyles.fieldTitleTextStyle,
                ),
              ),
              const SizedBox(width: TextFieldAutoCompleteEmailAddressWebStyles.space),
              Expanded(
                child: StatefulBuilder(
                  builder: ((context, setState) {
                    return Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        TagEditor<SuggestionEmailAddress>(
                          key: widget.keyTagEditor,
                          length: _collapsedListEmailAddress.length,
                          controller: widget.controller,
                          focusNodeKeyboard: widget.focusNode,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          cursorColor: TextFieldAutoCompleteEmailAddressWebStyles.cursorColor,
                          debounceDuration: TextFieldAutoCompleteEmailAddressWebStyles.debounceDuration,
                          inputDecoration: InputDecoration(
                            filled: true,
                            fillColor: TextFieldAutoCompleteEmailAddressWebStyles.textInputFillColor,
                            border: TextFieldAutoCompleteEmailAddressWebStyles.textInputBorder,
                            hintText: widget.field.getHintText(context),
                            hintStyle: TextFieldAutoCompleteEmailAddressWebStyles.textInputHintStyle,
                            isDense: true,
                            contentPadding: _getInputFieldPadding()
                          ),
                          padding: _getTagEditorPadding(context),
                          borderRadius: TextFieldAutoCompleteEmailAddressWebStyles.borderRadius,
                          borderSize: TextFieldAutoCompleteEmailAddressWebStyles.borderWidth,
                          focusedBorderColor: TextFieldAutoCompleteEmailAddressWebStyles.focusedBorderColor,
                          enableBorder: true,
                          enableBorderColor: AppColor.colorInputBorderCreateMailbox,
                          minTextFieldWidth: TextFieldAutoCompleteEmailAddressWebStyles.minTextFieldWidth,
                          resetTextOnSubmitted: true,
                          autoScrollToInput: false,
                          suggestionsBoxElevation: TextFieldAutoCompleteEmailAddressWebStyles.suggestionBoxElevation,
                          suggestionsBoxBackgroundColor: TextFieldAutoCompleteEmailAddressWebStyles.suggestionBoxBackgroundColor,
                          suggestionsBoxRadius: TextFieldAutoCompleteEmailAddressWebStyles.suggestionBoxRadius,
                          suggestionsBoxMaxHeight: TextFieldAutoCompleteEmailAddressWebStyles.suggestionBoxMaxHeight,
                          suggestionBoxWidth: _getSuggestionBoxWidth(constraints.maxWidth),
                          textStyle: AdvancedSearchInputFormStyle.inputTextStyle,
                          onFocusTagAction: (focused) => _handleFocusTagAction.call(focused, setState),
                          onDeleteTagAction: () => _handleDeleteLatestTagAction.call(setState),
                          onSelectOptionAction: (item) => _handleSelectOptionAction.call(item, setState),
                          onSubmitted: (value) => _handleSubmitTagAction.call(value, setState),
                          tagBuilder: (context, index) {
                            final currentEmailAddress = _currentListEmailAddress.elementAt(index);
                            final isLatestEmail = currentEmailAddress == _currentListEmailAddress.last;
                            return AutoCompleteTagItemWidgetWeb(
                              field: widget.field,
                              currentEmailAddress: currentEmailAddress,
                              currentListEmailAddress: _currentListEmailAddress,
                              collapsedListEmailAddress: _collapsedListEmailAddress,
                              isLatestEmail: isLatestEmail,
                              isCollapsed: _isCollapse,
                              isLatestTagFocused: _lastTagFocused,
                              onDeleteTagAction: (emailAddress) => _handleDeleteTagAction.call(emailAddress, setState),
                              onShowFullAction: widget.onShowFullListEmailAddressAction,
                            );
                          },
                          onTagChanged: (tag) => _handleOnTagChangeAction.call(tag, setState),
                          findSuggestions: _findSuggestions,
                          suggestionBuilder: (context, tagEditorState, suggestionEmailAddress, index, length, highlight, suggestionValid) {
                            return AutoCompleteSuggestionItemWidgetWeb(
                              suggestionState: suggestionEmailAddress.state,
                              emailAddress: suggestionEmailAddress.emailAddress,
                              suggestionValid: suggestionValid,
                              highlight: highlight,
                              onSelectedAction: (emailAddress) {
                                setState(() => _currentListEmailAddress.add(emailAddress));
                                _updateListEmailAddressAction();
                                tagEditorState.resetTextField();
                                tagEditorState.closeSuggestionBox();
                              },
                            );
                          },
                          onHandleKeyEventAction: (event) {
                            if (event is KeyDownEvent) {
                              switch (event.logicalKey) {
                                case LogicalKeyboardKey.tab:
                                  widget.nextFocusNode?.requestFocus();
                                  break;
                                default:
                                  break;
                              }
                            }
                          },
                        ),
                        if (_validateMeButtonDisplayed)
                          PositionedDirectional(
                            end: 8,
                            child: TMailButtonWidget.fromText(
                              text: AppLocalizations.of(context).me,
                              borderRadius: TextFieldAutoCompleteEmailAddressWebStyles.borderRadius,
                              textStyle: TextFieldAutoCompleteEmailAddressWebStyles.meButtonTextStyle,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              backgroundColor: AppColor.primaryColor,
                              maxWidth: TextFieldAutoCompleteEmailAddressWebStyles.meButtonMaxWidth,
                              minWidth: TextFieldAutoCompleteEmailAddressWebStyles.meButtonMinWidth,
                              onTapActionCallback: () =>
                                _handleOnClickMeButton(
                                  widget.userName!,
                                  setState
                                ),
                            )
                          )
                      ],
                    );
                  })
                ),
              ),
            ],
          );
        })
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
    if (processedQuery.length >= AppConfig.limitCharToStartSearch &&
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

  bool _isDuplicated(String inputEmail) {
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
    log('_TextFieldAutocompleteEmailAddressWebState::_handleGapBetweenTagChangedAndFindSuggestion:Timeout');
  }

  void _updateListEmailAddressAction() {
    widget.onUpdateListEmailAddressAction?.call(
      widget.field,
      _currentListEmailAddress
    );
  }

  void _handleFocusTagAction(bool focused, StateSetter stateSetter) {
    if (mounted) {
      stateSetter(() => _lastTagFocused = focused);
    }
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
  ) {
    if (!_isDuplicated(suggestionEmailAddress.emailAddress.emailAddress)) {
      stateSetter(() => _currentListEmailAddress.add(suggestionEmailAddress.emailAddress));
      _updateListEmailAddressAction();
    }
  }

  void _handleSubmitTagAction(
    String value,
    StateSetter stateSetter
  ) {
    final textTrim = value.trim();
    if (textTrim.isEmpty) {
      widget.onSearchAction?.call();
      return;
    }

    if (!_isDuplicated(textTrim)) {
      stateSetter(() => _currentListEmailAddress.add(EmailAddress(null, textTrim)));
      _updateListEmailAddressAction();
    }
  }

  void _handleOnTagChangeAction(
    String value,
    StateSetter stateSetter
  ) {
    final textTrim = value.trim();
    if (!_isDuplicated(textTrim)) {
      stateSetter(() => _currentListEmailAddress.add(EmailAddress(null, textTrim)));
      _updateListEmailAddressAction();
    }
    _gapBetweenTagChangedAndFindSuggestion = Timer(
      const Duration(seconds: 1),
      _handleGapBetweenTagChangedAndFindSuggestion
    );
  }

  double? _getSuggestionBoxWidth(double maxWidth) {
    if (maxWidth < ResponsiveUtils.minTabletWidth) {
      final newWidth = min(maxWidth, 300.0);
      return newWidth;
    } else {
      return null;
    }
  }

  EdgeInsets _getTagEditorPadding(BuildContext context) {
    if ( _currentListEmailAddress.isNotEmpty) {
      return _validateMeButtonDisplayed
        ? TextFieldAutoCompleteEmailAddressWebStyles.getTagEditorPaddingWithMeButton(context)
        : TextFieldAutoCompleteEmailAddressWebStyles.tagEditorPadding;
    }
    return EdgeInsets.zero;
  }

  EdgeInsetsGeometry _getInputFieldPadding() {
    if ( _currentListEmailAddress.isNotEmpty) {
      return TextFieldAutoCompleteEmailAddressWebStyles.textInputContentPaddingWithSomeTag;
    } else {
      return _validateMeButtonDisplayed
        ? TextFieldAutoCompleteEmailAddressWebStyles.textInputContentPaddingWithMeButton
        : TextFieldAutoCompleteEmailAddressWebStyles.textInputContentPadding;
    }
  }

  bool get _validateMeButtonDisplayed {
    return widget.userName != null && !_isMyEmailAddressExist(widget.userName!);
  }

  bool _isMyEmailAddressExist(UserName userName) {
    return _currentListEmailAddress
      .any((emailAddress) => emailAddress.emailAddress == userName.value);
  }

  void _handleOnClickMeButton(UserName userName, StateSetter stateSetter) {
    stateSetter(() => _currentListEmailAddress.add(EmailAddress(null, userName.value)));
    _updateListEmailAddressAction();
  }
}