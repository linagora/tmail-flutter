import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draggable_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/suggestion_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_suggestion_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/advanced_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/advanced_search_input_form_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/text_field_autocomplete_email_address_web_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/autocomplete_tag_item_widget_web.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/label_advanced_search_field_widget.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

typedef OnSuggestionEmailAddress = Future<List<EmailAddress>> Function(String word, {int? limit});
typedef OnUpdateListEmailAddressAction = void Function(AdvancedSearchFilterField field, List<EmailAddress> newData);
typedef OnDeleteEmailAddressTypeAction = void Function(AdvancedSearchFilterField field);
typedef OnShowFullListEmailAddressAction = void Function(AdvancedSearchFilterField field);
typedef OnDeleteTagAction = void Function(EmailAddress emailAddress);

class TextFieldAutocompleteEmailAddressWeb extends StatefulWidget {

  final AdvancedSearchFilterField field;
  final List<EmailAddress> listEmailAddress;
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
  final OnRemoveDraggableEmailAddressAction? onRemoveDraggableEmailAddressAction;
  final TextEditingController? controller;
  final VoidCallback? onSearchAction;
  final int minInputLengthAutocomplete;

  const TextFieldAutocompleteEmailAddressWeb({
    Key? key,
    required this.field,
    required this.listEmailAddress,
    this.expandMode = ExpandMode.EXPAND,
    this.minInputLengthAutocomplete = AppConfig.defaultMinInputLengthAutocomplete,
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
    this.onRemoveDraggableEmailAddressAction,
    this.controller,
    this.onSearchAction,
  }) : super(key: key);

  @override
  State<TextFieldAutocompleteEmailAddressWeb> createState() => _TextFieldAutocompleteEmailAddressWebState();
}

class _TextFieldAutocompleteEmailAddressWebState extends State<TextFieldAutocompleteEmailAddressWeb> {
  final _imagePaths = Get.find<ImagePaths>();

  bool _lastTagFocused = false;
  bool _isDragging = false;
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
                child: LabelAdvancedSearchFieldWidget(
                  name: widget.field.getTitle(context),
                ),
              ),
              const SizedBox(width: TextFieldAutoCompleteEmailAddressWebStyles.space),
              Expanded(
                child: StatefulBuilder(
                  builder: ((context, setState) {
                    return DragTarget<DraggableEmailAddress>(
                      onAcceptWithDetails: (draggableEmailAddress) =>
                        _handleAcceptDraggableEmailAddressAction(
                          draggableEmailAddress.data,
                          setState
                        ),
                      onLeave: (draggableEmailAddress) {
                        if (_isDragging) {
                          setState(() => _isDragging = false);
                        }
                      },
                      onMove: (details) {
                        if (!_isDragging) {
                          setState(() => _isDragging = true);
                        }
                      },
                      builder: (_, __, ___) {
                        return TagEditor<SuggestionEmailAddress>(
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
                            contentPadding: _currentListEmailAddress.isNotEmpty
                              ? TextFieldAutoCompleteEmailAddressWebStyles.textInputContentPaddingWithSomeTag
                              : TextFieldAutoCompleteEmailAddressWebStyles.textInputContentPadding
                          ),
                          padding: _currentListEmailAddress.isNotEmpty
                            ? TextFieldAutoCompleteEmailAddressWebStyles.tagEditorPadding
                            : EdgeInsets.zero,
                          borderRadius: TextFieldAutoCompleteEmailAddressWebStyles.borderRadius,
                          borderSize: TextFieldAutoCompleteEmailAddressWebStyles.borderWidth,
                          focusedBorderColor: TextFieldAutoCompleteEmailAddressWebStyles.focusedBorderColor,
                          enableBorder: true,
                          enableBorderColor: _isDragging
                            ? AppColor.primaryColor
                            : AppColor.colorInputBorderCreateMailbox,
                          minTextFieldWidth: TextFieldAutoCompleteEmailAddressWebStyles.minTextFieldWidth,
                          resetTextOnSubmitted: true,
                          autoScrollToInput: false,
                          suggestionsBoxElevation: TextFieldAutoCompleteEmailAddressWebStyles.suggestionBoxElevation,
                          suggestionsBoxBackgroundColor: TextFieldAutoCompleteEmailAddressWebStyles.suggestionBoxBackgroundColor,
                          suggestionsBoxRadius: TextFieldAutoCompleteEmailAddressWebStyles.suggestionBoxRadius,
                          suggestionsBoxMaxHeight: TextFieldAutoCompleteEmailAddressWebStyles.suggestionBoxMaxHeight,
                          suggestionItemHeight: TextFieldAutoCompleteEmailAddressWebStyles.suggestionBoxItemHeight,
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
                          findSuggestions: (queryString) => _findSuggestions(
                            queryString,
                            limit: AppConfig.defaultLimitAutocomplete,
                          ),
                          isLoadMoreOnlyOnce: true,
                          isLoadMoreReplaceAllOld: false,
                          loadMoreSuggestions: _findSuggestions,
                          suggestionBuilder: (context, tagEditorState, suggestionEmailAddress, index, length, highlight, suggestionValid) {
                            return RecipientSuggestionItemWidget(
                              imagePaths: _imagePaths,
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
                        );
                      }
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

  void _handleAcceptDraggableEmailAddressAction(
    DraggableEmailAddress draggableEmailAddress,
    StateSetter stateSetter
  ) {
    log('_TextFieldAutocompleteEmailAddressWebState::_handleAcceptDraggableEmailAddressAction:draggableEmailAddress = $draggableEmailAddress');
    if (draggableEmailAddress.prefix != widget.field.getPrefixEmailAddress()) {
      if (!_currentListEmailAddress.contains(draggableEmailAddress.emailAddress)) {
        stateSetter(() {
          _currentListEmailAddress.add(draggableEmailAddress.emailAddress);
          _isDragging = false;
        });
        _updateListEmailAddressAction();
      } else if (_isDragging) {
        stateSetter(() => _isDragging = false);
      }
      widget.onRemoveDraggableEmailAddressAction?.call(draggableEmailAddress);
    } else if (_isDragging) {
      stateSetter(() => _isDragging = false);
    }
  }
}