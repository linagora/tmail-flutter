import 'dart:async';
import 'dart:math';
import 'package:core/utils/app_logger.dart';
import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_field.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/styles/text_input_field/text_input_suggestion_field_widget_styles.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/text_input_field/suggestion_item_widget.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/text_input_field/suggestion_tag_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/suggesstion_email_address.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

typedef OnSuggestionEmailAddress = Future<List<EmailAddress>> Function(String word, {int? limit});
typedef OnUpdateListEmailAddressAction = void Function(EmailRecoveryField field, List<EmailAddress> newDate);
typedef OnDeleteEmailAddressTypeAction = void Function(EmailRecoveryField field, EmailAddress emailAddress);
typedef OnShowFullListEmailAddressAction = void Function(EmailRecoveryField field);
typedef OnDeleteTagAction = void Function(EmailAddress emailAddress);

class TextInputFieldSuggestionWidget extends StatefulWidget {
  final EmailRecoveryField field;
  final List<EmailAddress> listEmailAddress;
  final ExpandMode expandMode;
  final ResponsiveUtils responsiveUtils;
  final FocusNode? focusNode;
  final GlobalKey? keyTagEditor;
  final FocusNode? nextFocusNode;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final OnSuggestionEmailAddress? onSuggestionEmailAddress;
  final OnUpdateListEmailAddressAction? onUpdateListEmailAddressAction;
  final OnDeleteEmailAddressTypeAction? onDeleteEmailAddressTypeAction;
  final OnShowFullListEmailAddressAction? onShowFullListEmailAddressAction;
  final OnDeleteTagAction? onDeleteTagAction;
  final TextEditingController? textEditingController;
  final VoidCallback? onCreateAction;
  final int minInputLengthAutocomplete;

  const TextInputFieldSuggestionWidget({
    super.key,
    required this.field,
    required this.listEmailAddress,
    required this.responsiveUtils,
    this.expandMode = ExpandMode.EXPAND,
    this.minInputLengthAutocomplete = AppConfig.defaultMinInputLengthAutocomplete,
    this.focusNode,
    this.keyTagEditor,
    this.nextFocusNode,
    this.padding,
    this.margin,
    this.onSuggestionEmailAddress,
    this.onUpdateListEmailAddressAction,
    this.onDeleteEmailAddressTypeAction,
    this.onShowFullListEmailAddressAction,
    this.onDeleteTagAction,
    this.textEditingController,
    this.onCreateAction,
  });

  @override
  State<TextInputFieldSuggestionWidget> createState() => _TextInputFieldSuggestionWidgetState();
}

class _TextInputFieldSuggestionWidgetState extends State<TextInputFieldSuggestionWidget> {
  bool _lastTagFocused = false;
  late List<EmailAddress> _currentListEmailAddress;
  Timer? _gapBetweenTagChangedAndFindSuggestion;

  @override
  void initState() {
    super.initState();
    _currentListEmailAddress = widget.listEmailAddress;
  }

  @override
  void didUpdateWidget(covariant TextInputFieldSuggestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listEmailAddress != oldWidget.listEmailAddress) {
      _currentListEmailAddress = widget.listEmailAddress;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: TextInputSuggestionFieldWidgetStyles.padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final title = SizedBox(
            width: TextInputSuggestionFieldWidgetStyles.titleWidth,
            child: Text(
              widget.field.getTitle(context),
              style: widget.field.getTitleTextStyle(),
            ),
          );
          final inputField = StatefulBuilder(
            builder: (context, setState) {
              return TagEditor<SuggestionEmailAddress>(
                key: widget.keyTagEditor,
                length: _collapsedListEmailAddress.length,
                controller: widget.textEditingController,
                focusNodeKeyboard: widget.focusNode,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                debounceDuration: const Duration(milliseconds: 150),
                enabled: widget.field == EmailRecoveryField.sender && _currentListEmailAddress.length == 1
                  ? false
                  : true,
                inputDecoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: TextInputSuggestionFieldWidgetStyles.border,
                  hintText: widget.field.getHintText(context),
                  hintStyle: widget.field.getHintTextStyle(),
                  isDense: true,
                  contentPadding:  _currentListEmailAddress.isNotEmpty
                    ? TextInputSuggestionFieldWidgetStyles.contentPadding
                    : TextInputSuggestionFieldWidgetStyles.emptyListContentPadding,
                ),
                padding: _currentListEmailAddress.isNotEmpty
                  ? TextInputSuggestionFieldWidgetStyles.inputFieldPadding
                  : EdgeInsets.zero,
                borderRadius: TextInputSuggestionFieldWidgetStyles.borderRadius,
                borderSize: TextInputSuggestionFieldWidgetStyles.borderSize,
                focusedBorderColor: AppColor.primaryColor,
                enableBorder: true,
                enableBorderColor: AppColor.colorInputBorderCreateMailbox,
                minTextFieldWidth: TextInputSuggestionFieldWidgetStyles.minTextFieldWidth,
                resetTextOnSubmitted: true,
                autoScrollToInput: false,
                suggestionsBoxElevation: TextInputSuggestionFieldWidgetStyles.suggestionsBoxElevation,
                suggestionsBoxBackgroundColor: Colors.white,
                suggestionsBoxRadius: TextInputSuggestionFieldWidgetStyles.suggestionsBoxRadius,
                suggestionsBoxMaxHeight: TextInputSuggestionFieldWidgetStyles.suggestionsBoxMaxHeight,
                suggestionBoxWidth: _getSuggestionBoxWidth(constraints.maxWidth),
                textStyle: TextInputSuggestionFieldWidgetStyles.inputFieldTextStyle,
                onFocusTagAction: (focused) => _handleFocusTagAction.call(focused, setState),
                onDeleteTagAction: () => _handleDeleteLatestTagAction.call(setState),
                onSelectOptionAction: (item) => _handleSelectOptionAction.call(item, setState),
                onSubmitted: (value) => _handleSubmitTagAction.call(value, setState),
                tagBuilder: (context, index) {
                  final currentEmailAddress = _currentListEmailAddress.elementAt(index);
                  final isLatestEmail = currentEmailAddress == _currentListEmailAddress.last;
                  return SuggestionTagItemWidget(
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
                  return SuggestionItemWidget(
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
            },
          );

          if (widget.responsiveUtils.isMobile(context)) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                title,
                const SizedBox(height: TextInputSuggestionFieldWidgetStyles.spaceMobile),
                inputField,
              ]
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                title,
                const SizedBox(width: TextInputSuggestionFieldWidgetStyles.space),
                Expanded(
                  child: inputField,
                )
              ],
            );
          }
        },
      ),
    );
  }

  bool get _isCollapse => _currentListEmailAddress.length > 1 && widget.expandMode == ExpandMode.COLLAPSE;

  List<EmailAddress> get _collapsedListEmailAddress => _isCollapse
    ? _currentListEmailAddress.sublist(0, 1)
    : _currentListEmailAddress;
  
  double? _getSuggestionBoxWidth(double maxWidth) {
    if (maxWidth < ResponsiveUtils.minTabletWidth) {
      final newWidth = min(maxWidth, 300.0);
      return newWidth;
    } else {
      return null;
    }
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

  void _updateListEmailAddressAction() {
    widget.onUpdateListEmailAddressAction?.call(
      widget.field,
      _currentListEmailAddress
    );
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

  bool _isDuplicated(String inputEmail) {
    if (inputEmail.isEmpty) {
      return false;
    }
    return _currentListEmailAddress
      .map((emailAddress) => emailAddress.email)
      .whereNotNull()
      .contains(inputEmail);
  }

  void _handleSubmitTagAction(
    String value,
    StateSetter stateSetter
  ) {
    final textTrim = value.trim();
    if (textTrim.isEmpty) {
      widget.onCreateAction?.call();
      return;
    }

    if (!_isDuplicated(textTrim)) {
      stateSetter(() => _currentListEmailAddress.add(EmailAddress(null, textTrim)));
      _updateListEmailAddressAction();
    }
  }

  void _handleDeleteTagAction(EmailAddress emailAddress, StateSetter stateSetter) {
    if (_currentListEmailAddress.isNotEmpty) {
      stateSetter(() => _currentListEmailAddress.remove(emailAddress));
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

  void _handleGapBetweenTagChangedAndFindSuggestion() {
    log('_TextFieldAutocompleteEmailAddressWebState::_handleGapBetweenTagChangedAndFindSuggestion:Timeout');
  }

  FutureOr<List<SuggestionEmailAddress>> _findSuggestions(String query, {int? limit}) async {
    if (_gapBetweenTagChangedAndFindSuggestion?.isActive ?? false) {
      return [];
    }

    final processedQuery = query.trim();
    if (processedQuery.isEmpty) {
      return [];
    }

    final tmailSuggestion = List<SuggestionEmailAddress>.empty(growable: true);
    if (
      processedQuery.length >= widget.minInputLengthAutocomplete
      && widget.onSuggestionEmailAddress != null
    ) {
      final listEmailAddress = await widget.onSuggestionEmailAddress!(
        processedQuery,
        limit: limit,
      );
      log('_TextFieldAutocompleteEmailAddressWebState::_findSuggestions: listEmailAddress: $listEmailAddress');
      final listSuggestionEmailAddress =  listEmailAddress.map((emailAddress) => _toSuggestionEmailAddress(emailAddress, _currentListEmailAddress));
      tmailSuggestion.addAll(listSuggestionEmailAddress);
    }

    tmailSuggestion.addAll(_matchedSuggestionEmailAddress(processedQuery, _currentListEmailAddress));

    final currentTextOnTextField = widget.textEditingController?.text ?? '';
    if (currentTextOnTextField.isEmpty) {
      return [];
    }

    return tmailSuggestion.toSet().toList();
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
}