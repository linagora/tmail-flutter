
import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draggable_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/recipient_action.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/suggestion_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/recipient_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_suggestion_item_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_tag_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

typedef OnSuggestionEmailAddress = Future<List<EmailAddress>> Function(String word);
typedef OnUpdateListEmailAddressAction = void Function(PrefixEmailAddress prefix, List<EmailAddress> newData);
typedef OnAddEmailAddressTypeAction = void Function(PrefixEmailAddress prefix);
typedef OnDeleteEmailAddressTypeAction = void Function(PrefixEmailAddress prefix);
typedef OnShowFullListEmailAddressAction = void Function(PrefixEmailAddress prefix);
typedef OnFocusEmailAddressChangeAction = void Function(PrefixEmailAddress prefix, bool isFocus);
typedef OnRemoveDraggableEmailAddressAction = void Function(DraggableEmailAddress draggableEmailAddress);
typedef OnDeleteTagAction = void Function(EmailAddress emailAddress);
typedef OnSelectRecipientAction = void Function(RecipientAction action, PrefixEmailAddress prefix, EmailAddress emailAddress);

class RecipientComposerWidget extends StatefulWidget {

  final PrefixEmailAddress prefix;
  final List<EmailAddress> listEmailAddress;
  final ExpandMode expandMode;
  final PrefixRecipientState fromState;
  final PrefixRecipientState ccState;
  final PrefixRecipientState bccState;
  final bool? isInitial;
  final FocusNode? focusNode;
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
  final OnSelectRecipientAction? onSelectRecipientAction;
  final VoidCallback? onFocusNextAddressAction;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const RecipientComposerWidget({
    super.key,
    required this.prefix,
    required this.listEmailAddress,
    this.ccState = PrefixRecipientState.disabled,
    this.bccState = PrefixRecipientState.disabled,
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
    this.onSelectRecipientAction,
  });

  @override
  State<RecipientComposerWidget> createState() => _RecipientComposerWidgetState();
}

class _RecipientComposerWidgetState extends State<RecipientComposerWidget> {

  Timer? _gapBetweenTagChangedAndFindSuggestion;
  bool _lastTagFocused = false;
  bool _isDragging = false;
  late List<EmailAddress> _currentListEmailAddress;

  final _imagePaths = Get.find<ImagePaths>();

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
    return LayoutBuilder(builder: (context, constraints) {
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
                  child: StatefulBuilder(
                    builder: (context, stateSetter) {
                      if (PlatformInfo.isWeb) {
                        return DragTarget<DraggableEmailAddress>(
                          builder: (context, candidateData, rejectedData) {
                            return GestureDetector(
                              onTap: () => _isCollapse
                                ? widget.onShowFullListEmailAddressAction?.call(widget.prefix)
                                : null,
                              child: TagEditor<SuggestionEmailAddress>(
                                key: widget.keyTagEditor,
                                length: _collapsedListEmailAddress.length,
                                controller: widget.controller,
                                focusNode: widget.focusNode,
                                enableBorder: _isDragging,
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
                                cursorColor: RecipientComposerWidgetStyle.cursorColor,
                                suggestionsBoxElevation: RecipientComposerWidgetStyle.suggestionsBoxElevation,
                                suggestionsBoxBackgroundColor: RecipientComposerWidgetStyle.suggestionsBoxBackgroundColor,
                                suggestionsBoxRadius: RecipientComposerWidgetStyle.suggestionsBoxRadius,
                                suggestionsBoxMaxHeight: RecipientComposerWidgetStyle.suggestionsBoxMaxHeight,
                                suggestionBoxWidth: _getSuggestionBoxWidth(constraints.maxWidth),
                                textStyle: RecipientComposerWidgetStyle.inputTextStyle,
                                onFocusTagAction: (focused) => _handleFocusTagAction.call(focused, stateSetter),
                                onDeleteTagAction: () => _handleDeleteLatestTagAction.call(stateSetter),
                                onSelectOptionAction: (item) => _handleSelectOptionAction.call(item, stateSetter),
                                onSubmitted: (value) => _handleSubmitTagAction.call(value, stateSetter),
                                onTapOutside: (_) {},
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
                                    maxWidth: constraints.maxWidth,
                                    onDeleteTagAction: (emailAddress) => _handleDeleteTagAction.call(emailAddress, stateSetter),
                                    onShowFullAction: widget.onShowFullListEmailAddressAction,
                                    onSelectRecipientAction: (action, prefix, emailAddress) {
                                      _handleSelectRecipientAction(
                                        action: action,
                                        prefix: prefix,
                                        emailAddress: emailAddress,
                                        stateSetter: stateSetter
                                      );
                                    },
                                  );
                                },
                                onTagChanged: (value) => _handleOnTagChangeAction.call(value, stateSetter),
                                findSuggestions: _findSuggestions,
                                useDefaultHighlight: false,
                                suggestionBuilder: (context, tagEditorState, suggestionEmailAddress, index, length, highlight, suggestionValid) {
                                  return RecipientSuggestionItemWidget(
                                    suggestionState: suggestionEmailAddress.state,
                                    emailAddress: suggestionEmailAddress.emailAddress,
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
                              ),
                            );
                          },
                          onAccept: (draggableEmailAddress) => _handleAcceptDraggableEmailAddressAction(draggableEmailAddress, stateSetter),
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
                        return GestureDetector(
                          onTap: () => _isCollapse
                            ? widget.onShowFullListEmailAddressAction?.call(widget.prefix)
                            : null,
                          child: TagEditor<SuggestionEmailAddress>(
                            key: widget.keyTagEditor,
                            length: _collapsedListEmailAddress.length,
                            controller: widget.controller,
                            focusNode: widget.focusNode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            debounceDuration: RecipientComposerWidgetStyle.suggestionDebounceDuration,
                            tagSpacing: RecipientComposerWidgetStyle.tagSpacing,
                            autofocus: widget.prefix != PrefixEmailAddress.to && _currentListEmailAddress.isEmpty,
                            minTextFieldWidth: RecipientComposerWidgetStyle.minTextFieldWidth,
                            resetTextOnSubmitted: true,
                            autoScrollToInput: false,
                            cursorColor: RecipientComposerWidgetStyle.cursorColor,
                            suggestionsBoxElevation: RecipientComposerWidgetStyle.suggestionsBoxElevation,
                            suggestionsBoxBackgroundColor: RecipientComposerWidgetStyle.suggestionsBoxBackgroundColor,
                            suggestionsBoxRadius: RecipientComposerWidgetStyle.suggestionsBoxRadius,
                            suggestionsBoxMaxHeight: RecipientComposerWidgetStyle.suggestionsBoxMaxHeight,
                            suggestionBoxWidth: _getSuggestionBoxWidth(constraints.maxWidth),
                            textStyle: RecipientComposerWidgetStyle.inputTextStyle,
                            onFocusTagAction: (focused) => _handleFocusTagAction.call(focused, stateSetter),
                            onDeleteTagAction: () => _handleDeleteLatestTagAction.call(stateSetter),
                            onSelectOptionAction: (item) => _handleSelectOptionAction.call(item, stateSetter),
                            onSubmitted: (value) => _handleSubmitTagAction.call(value, stateSetter),
                            onTapOutside: (_) {},
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
                                maxWidth: constraints.maxWidth,
                                onDeleteTagAction: (emailAddress) => _handleDeleteTagAction.call(emailAddress, stateSetter),
                                onShowFullAction: widget.onShowFullListEmailAddressAction,
                                onSelectRecipientAction: (action, prefix, emailAddress) {
                                  _handleSelectRecipientAction(
                                    action: action,
                                    prefix: prefix,
                                    emailAddress: emailAddress,
                                    stateSetter: stateSetter
                                  );
                                },
                              );
                            },
                            onTagChanged: (value) => _handleOnTagChangeAction.call(value, stateSetter),
                            findSuggestions: _findSuggestions,
                            useDefaultHighlight: false,
                            suggestionBuilder: (context, tagEditorState, suggestionEmailAddress, index, length, highlight, suggestionValid) {
                              return RecipientSuggestionItemWidget(
                                suggestionState: suggestionEmailAddress.state,
                                emailAddress: suggestionEmailAddress.emailAddress,
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
                          ),
                        );
                      }
                    },
                  )
                )
              )
            ),
            const SizedBox(width: RecipientComposerWidgetStyle.space),
            if (widget.prefix == PrefixEmailAddress.to && widget.fromState == PrefixRecipientState.disabled)
              TMailButtonWidget.fromText(
                text: AppLocalizations.of(context).from_email_address_prefix,
                textStyle: RecipientComposerWidgetStyle.prefixButtonTextStyle,
                backgroundColor: Colors.transparent,
                padding: RecipientComposerWidgetStyle.prefixButtonPadding,
                margin: RecipientComposerWidgetStyle.recipientMargin,
                onTapActionCallback: () => widget.onAddEmailAddressTypeAction?.call(PrefixEmailAddress.from),
              ),
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
    });
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
  ) {
    if (!_isDuplicatedRecipient(suggestionEmailAddress.emailAddress.emailAddress)) {
      stateSetter(() => _currentListEmailAddress.add(suggestionEmailAddress.emailAddress));
      _updateListEmailAddressAction();
    }
  }

  void _handleSubmitTagAction(
    String value,
    StateSetter stateSetter
  ) {
    final textTrim = value.trim();
    if (!_isDuplicatedRecipient(textTrim)) {
      stateSetter(() => _currentListEmailAddress.add(EmailAddress(null, textTrim)));
      _updateListEmailAddressAction();
    }
  }

  void _handleOnTagChangeAction(
    String value,
    StateSetter stateSetter
  ) {
    final textTrim = value.trim();
    if (!_isDuplicatedRecipient(textTrim)) {
      stateSetter(() => _currentListEmailAddress.add(EmailAddress(null, textTrim)));
      _updateListEmailAddressAction();
    }
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

  void _handleSelectRecipientAction({
    required RecipientAction action,
    required PrefixEmailAddress prefix,
    required EmailAddress emailAddress,
    required StateSetter stateSetter,
  }) {
    switch(action) {
      case RecipientAction.changeEmailAddress:
        _handleChangeEmailAddress(
          prefix: prefix,
          emailAddress: emailAddress,
          stateSetter: stateSetter
        );
        break;
    }
    widget.onSelectRecipientAction?.call(action, prefix, emailAddress);
  }

  void _handleChangeEmailAddress({
    required PrefixEmailAddress prefix,
    required EmailAddress emailAddress,
    required StateSetter stateSetter,
  }) {
    if (_currentListEmailAddress.isNotEmpty) {
      stateSetter(() => _currentListEmailAddress.remove(emailAddress));
      _updateListEmailAddressAction();
    }

    if (widget.controller != null) {
      widget.controller!.text = emailAddress.emailAddress;
      widget.controller!.value = widget.controller!.value.copyWith(
        text: emailAddress.emailAddress,
        selection: TextSelection(
          baseOffset: emailAddress.emailAddress.length,
          extentOffset: emailAddress.emailAddress.length,
        ),
        composing: TextRange.empty
      );
    }

    widget.focusNode?.requestFocus();
  }
}