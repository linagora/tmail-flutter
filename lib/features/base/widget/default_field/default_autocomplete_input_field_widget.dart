import 'dart:async';
import 'dart:math';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_autocomplete_tag_item_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draggable_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/suggestion_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_suggestion_item_widget.dart';
import 'package:tmail_ui_user/features/base/model/filter_filter.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

typedef OnSuggestionEmailAddress = Future<List<EmailAddress>> Function(
  String word, {
  int? limit,
});
typedef OnUpdateListEmailAddressAction = void Function(
  FilterField field,
  List<EmailAddress> newData,
);
typedef OnDeleteEmailAddressTypeAction = void Function(FilterField field);
typedef OnShowFullListEmailAddressAction = void Function(FilterField field);
typedef OnDeleteTagAction = void Function(EmailAddress emailAddress);

class DefaultAutocompleteInputFieldWidget extends StatefulWidget {
  final FilterField field;
  final List<EmailAddress> listEmailAddress;
  final ExpandMode expandMode;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final GlobalKey? keyTagEditor;
  final FocusNode? nextFocusNode;
  final EdgeInsetsGeometry? padding;
  final int minInputLengthAutocomplete;
  final OnSuggestionEmailAddress? onSuggestionEmailAddress;
  final OnDeleteTagAction? onDeleteTag;
  final OnUpdateListEmailAddressAction? onUpdateListEmailAddressAction;
  final OnDeleteEmailAddressTypeAction? onDeleteEmailAddressTypeAction;
  final OnShowFullListEmailAddressAction? onShowFullListEmailAddressAction;
  final OnRemoveDraggableEmailAddressAction?
      onRemoveDraggableEmailAddressAction;
  final VoidCallback? onSearchAction;

  const DefaultAutocompleteInputFieldWidget({
    Key? key,
    required this.field,
    required this.listEmailAddress,
    this.expandMode = ExpandMode.EXPAND,
    this.minInputLengthAutocomplete =
        AppConfig.defaultMinInputLengthAutocomplete,
    this.focusNode,
    this.keyTagEditor,
    this.nextFocusNode,
    this.padding,
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
  State<DefaultAutocompleteInputFieldWidget> createState() =>
      _DefaultAutocompleteInputFieldWidgetState();
}

class _DefaultAutocompleteInputFieldWidgetState
    extends State<DefaultAutocompleteInputFieldWidget> {
  final _imagePaths = Get.find<ImagePaths>();

  int _tagIndexFocused = -1;
  bool _isDragging = false;
  late List<EmailAddress> _currentListEmailAddress;
  Timer? _gapBetweenTagChangedAndFindSuggestion;

  @override
  void initState() {
    super.initState();
    _currentListEmailAddress = widget.listEmailAddress;
  }

  @override
  void didUpdateWidget(
    covariant DefaultAutocompleteInputFieldWidget oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (widget.listEmailAddress != oldWidget.listEmailAddress) {
      _currentListEmailAddress = widget.listEmailAddress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodyWidget = LayoutBuilder(builder: ((_, constraints) {
      final tagEditor = TagEditor<SuggestionEmailAddress>(
        key: widget.keyTagEditor,
        length: _collapsedListEmailAddress.length,
        controller: widget.controller,
        focusNodeKeyboard: widget.focusNode,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        cursorColor: AppColor.primaryColor,
        debounceDuration: const Duration(milliseconds: 150),
        inputDecoration: InputDecoration(
          filled: true,
          constraints: const BoxConstraints(maxHeight: 40),
          fillColor: Colors.white,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide.none,
          ),
          hintText: widget.field.getHintText(AppLocalizations.of(context)),
          hintStyle: ThemeUtils.textStyleBodyBody3(
            color: AppColor.m3Tertiary,
          ),
          isDense: true,
          contentPadding: _getTextFieldContentPadding(),
        ),
        padding: _getTagEditorPadding(),
        tagSpacing: PlatformInfo.isWeb ? 4.0 : 8.0,
        borderRadius: 10,
        borderSize: 1,
        focusedBorderColor: AppColor.primaryColor,
        enableBorder: true,
        enableBorderColor:
            _isDragging ? AppColor.primaryColor : AppColor.m3Neutral90,
        minTextFieldWidth: 40.0,
        resetTextOnSubmitted: true,
        autoScrollToInput: false,
        suggestionsBoxElevation: 20,
        suggestionsBoxBackgroundColor: Colors.white,
        suggestionsBoxRadius: 20,
        suggestionsBoxMaxHeight: 350,
        suggestionItemHeight: 60,
        suggestionBoxWidth: _getSuggestionBoxWidth(constraints.maxWidth),
        textStyle: ThemeUtils.textStyleBodyBody3(
          color: AppColor.m3SurfaceBackground,
        ),
        onFocusTagAction: _handleFocusTagAction,
        onDeleteTagAction: _handleDeleteLatestTagAction,
        onSelectOptionAction: _handleSelectOptionAction,
        onSubmitted: _handleSubmitTagAction,
        tagBuilder: (context, index) {
          final currentEmailAddress = _currentListEmailAddress.elementAt(index);
          return DefaultAutocompleteTagItemWidget(
            field: widget.field,
            imagePaths: _imagePaths,
            currentEmailAddress: currentEmailAddress,
            currentListEmailAddress: _currentListEmailAddress,
            collapsedListEmailAddress: _collapsedListEmailAddress,
            iconClose: _imagePaths.icClose,
            isCollapsed: _isCollapse,
            isTagFocused: _tagIndexFocused == index,
            onDeleteTagAction: _handleDeleteTagAction,
            onShowFullAction: widget.onShowFullListEmailAddressAction,
          );
        },
        onTagChanged: _handleOnTagChangeAction,
        findSuggestions: (queryString) => _findSuggestions(
          queryString,
          limit: AppConfig.defaultLimitAutocomplete,
        ),
        isLoadMoreOnlyOnce: true,
        isLoadMoreReplaceAllOld: false,
        loadMoreSuggestions: _findSuggestions,
        suggestionBuilder: (
          context,
          tagEditorState,
          suggestionEmailAddress,
          index,
          length,
          highlight,
          suggestionValid,
        ) {
          return RecipientSuggestionItemWidget(
            imagePaths: _imagePaths,
            suggestionState: suggestionEmailAddress.state,
            emailAddress: suggestionEmailAddress.emailAddress,
            suggestionValid: suggestionValid,
            highlight: highlight,
            onSelectedAction: (emailAddress) {
              _setStateSafety(() => _currentListEmailAddress.add(emailAddress));
              _updateListEmailAddressAction();
              tagEditorState.resetTextField();
              tagEditorState.closeSuggestionBox();
            },
          );
        },
        onHandleKeyEventAction:
            widget.nextFocusNode == null ? null : _onKeyEvent,
      );

      if (PlatformInfo.isWeb) {
        return DragTarget<DraggableEmailAddress>(
          onAcceptWithDetails: (draggableEmailAddress) => _onAcceptWithDetails(
            draggableEmailAddress.data,
          ),
          onLeave: (_) {
            if (_isDragging) {
              _setStateSafety(() => _isDragging = false);
            }
          },
          onMove: (_) {
            if (!_isDragging) {
              _setStateSafety(() => _isDragging = true);
            }
          },
          builder: (_, __, ___) => tagEditor,
        );
      } else {
        return tagEditor;
      }
    }));

    if (widget.padding != null) {
      return Padding(padding: widget.padding!, child: bodyWidget);
    } else {
      return bodyWidget;
    }
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
      widget.nextFocusNode?.requestFocus();
    }
  }

  bool get _isCollapse =>
      _currentListEmailAddress.length > 1 &&
      widget.expandMode == ExpandMode.COLLAPSE;

  List<EmailAddress> get _collapsedListEmailAddress => _isCollapse
      ? _currentListEmailAddress.sublist(0, 1)
      : _currentListEmailAddress;

  FutureOr<List<SuggestionEmailAddress>> _findSuggestions(
    String query, {
    int? limit,
  }) async {
    if (_gapBetweenTagChangedAndFindSuggestion?.isActive ?? false) {
      return [];
    }

    final processedQuery = query.trim();
    if (processedQuery.isEmpty) {
      return [];
    }

    final displayedSuggestion =
        List<SuggestionEmailAddress>.empty(growable: true);
    if (processedQuery.length >= widget.minInputLengthAutocomplete &&
        widget.onSuggestionEmailAddress != null) {
      final listEmailAddress = await widget.onSuggestionEmailAddress!(
        processedQuery,
        limit: limit,
      );
      final listSuggestionEmailAddress =
          listEmailAddress.map((emailAddress) => _toSuggestionEmailAddress(
                emailAddress,
                _currentListEmailAddress,
              ));
      displayedSuggestion.addAll(listSuggestionEmailAddress);
    }

    displayedSuggestion.addAll(_matchedSuggestionEmailAddress(
      processedQuery,
      _currentListEmailAddress,
    ));

    final currentTextOnTextField = widget.controller?.text ?? '';
    if (currentTextOnTextField.isEmpty) {
      return [];
    }

    return displayedSuggestion.toSet().toList();
  }

  bool _isDuplicated(String inputEmail) {
    if (inputEmail.isEmpty) {
      return false;
    }
    return _currentListEmailAddress
        .map((emailAddress) => emailAddress.email)
        .nonNulls
        .contains(inputEmail);
  }

  SuggestionEmailAddress _toSuggestionEmailAddress(
    EmailAddress item,
    List<EmailAddress> addedEmailAddresses,
  ) {
    if (addedEmailAddresses.contains(item)) {
      return SuggestionEmailAddress(
        item,
        state: SuggestionEmailState.duplicated,
      );
    } else {
      return SuggestionEmailAddress(item);
    }
  }

  Iterable<SuggestionEmailAddress> _matchedSuggestionEmailAddress(
    String query,
    List<EmailAddress> addedEmailAddress,
  ) {
    return addedEmailAddress
        .where((addedMail) => addedMail.emailAddress.contains(query))
        .map((emailAddress) => SuggestionEmailAddress(
              emailAddress,
              state: SuggestionEmailState.duplicated,
            ));
  }

  void _updateListEmailAddressAction() {
    widget.onUpdateListEmailAddressAction?.call(
      widget.field,
      _currentListEmailAddress,
    );
  }

  void _handleFocusTagAction(int index) {
    _setStateSafety(() => _tagIndexFocused = index);
  }

  void _handleDeleteLatestTagAction(int index) {
    if (_currentListEmailAddress.isNotEmpty &&
        index >= 0 &&
        index < _currentListEmailAddress.length) {
      _setStateSafety(() {
        _currentListEmailAddress.removeAt(index);
      });
      _updateListEmailAddressAction();
    }
  }

  void _handleDeleteTagAction(EmailAddress emailAddress) {
    if (_currentListEmailAddress.isNotEmpty) {
      _setStateSafety(() => _currentListEmailAddress.remove(emailAddress));
      _updateListEmailAddressAction();
    }
  }

  void _handleSelectOptionAction(
    SuggestionEmailAddress suggestionEmailAddress,
  ) {
    if (!_isDuplicated(suggestionEmailAddress.emailAddress.emailAddress)) {
      _setStateSafety(
        () => _currentListEmailAddress.add(suggestionEmailAddress.emailAddress),
      );
      _updateListEmailAddressAction();
    }
  }

  void _handleSubmitTagAction(String value) {
    final textTrim = value.trim();
    if (textTrim.isEmpty) {
      widget.onSearchAction?.call();
      return;
    }

    if (!_isDuplicated(textTrim)) {
      _setStateSafety(
        () => _currentListEmailAddress.add(EmailAddress(null, textTrim)),
      );
      _updateListEmailAddressAction();
    }
  }

  void _handleOnTagChangeAction(String value) {
    final textTrim = value.trim();
    if (!_isDuplicated(textTrim)) {
      _setStateSafety(
        () => _currentListEmailAddress.add(EmailAddress(null, textTrim)),
      );
      _updateListEmailAddressAction();
    }
    _gapBetweenTagChangedAndFindSuggestion = Timer(
      const Duration(seconds: 1),
      () {},
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

  void _onAcceptWithDetails(DraggableEmailAddress draggableEmailAddress) {
    if (draggableEmailAddress.filterField != widget.field) {
      if (!_currentListEmailAddress
          .contains(draggableEmailAddress.emailAddress)) {
        _setStateSafety(() {
          _currentListEmailAddress.add(draggableEmailAddress.emailAddress);
          _isDragging = false;
        });
        _updateListEmailAddressAction();
      } else if (_isDragging) {
        _setStateSafety(() => _isDragging = false);
      }
      widget.onRemoveDraggableEmailAddressAction?.call(draggableEmailAddress);
    } else if (_isDragging) {
      _setStateSafety(() => _isDragging = false);
    }
  }

  void _setStateSafety(VoidCallback onAction) {
    if (mounted) {
      setState(onAction);
    }
  }

  EdgeInsetsGeometry? _getTextFieldContentPadding() {
    if (_currentListEmailAddress.isNotEmpty) {
      if (PlatformInfo.isWeb) {
        return const EdgeInsetsDirectional.symmetric(
          vertical: 14,
          horizontal: 4,
        );
      } else {
        return const EdgeInsetsDirectional.symmetric(vertical: 12);
      }
    } else {
      if (PlatformInfo.isWeb) {
        return const EdgeInsetsDirectional.only(
          top: 14,
          bottom: 14,
          start: 12,
          end: 8,
        );
      } else {
        return const EdgeInsetsDirectional.all(12);
      }
    }
  }

  EdgeInsets? _getTagEditorPadding() {
    if (_currentListEmailAddress.isNotEmpty) {
      if (PlatformInfo.isWeb) {
        return const EdgeInsets.symmetric(horizontal: 12);
      } else {
        return const EdgeInsets.only(left: 12, right: 12, bottom: 9);
      }
    } else {
      return null;
    }
  }
}
