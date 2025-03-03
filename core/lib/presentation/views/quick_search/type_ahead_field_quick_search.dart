import 'dart:async';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/quick_search/quick_search_action_define.dart';
import 'package:core/presentation/views/quick_search/quick_search_suggestion_box.dart';
import 'package:core/presentation/views/quick_search/quick_search_suggestion_box_controller.dart';
import 'package:core/presentation/views/quick_search/quick_search_suggestion_box_decoration.dart';
import 'package:core/presentation/views/quick_search/quick_search_suggestion_list.dart';
import 'package:core/presentation/views/quick_search/quick_search_text_field_configuration.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

/// A [TextField](https://docs.flutter.io/flutter/material/TextField-class.html)
/// that displays a list of suggestions as the user types
///
/// See also:
///
/// * [QuickSearchInputForm], a [FormField](https://docs.flutter.io/flutter/widgets/FormField-class.html)
/// implementation of [TypeAheadFieldQuickSearch] that allows the value to be saved,
/// validated, etc.
class TypeAheadFieldQuickSearch<T, P, R> extends StatefulWidget {
  /// Called with the search pattern to get the search suggestions.
  ///
  /// This callback must not be null. It is be called by the TypeAhead widget
  /// and provided with the search pattern. It should return a [List](https://api.dartlang.org/stable/2.0.0/dart-core/List-class.html)
  /// of suggestions either synchronously, or asynchronously (as the result of a
  /// [Future](https://api.dartlang.org/stable/dart-async/Future-class.html)).
  /// Typically, the list of suggestions should not contain more than 4 or 5
  /// entries. These entries will then be provided to [itemBuilder] to display
  /// the suggestions.
  ///
  /// Example:
  /// ```dart
  /// suggestionsCallback: (pattern) async {
  ///   return await _getSuggestions(pattern);
  /// }
  /// ```
  final SuggestionsCallback<T> suggestionsCallback;

  /// Called when a suggestion is tapped.
  ///
  /// This callback must not be null. It is called by the TypeAhead widget and
  /// provided with the value of the tapped suggestion.
  ///
  /// For example, you might want to navigate to a specific view when the user
  /// tabs a suggestion:
  /// ```dart
  /// onSuggestionSelected: (suggestion) {
  ///   Navigator.of(context).push(MaterialPageRoute(
  ///     builder: (context) => SearchResult(
  ///       searchItem: suggestion
  ///     )
  ///   ));
  /// }
  /// ```
  ///
  /// Or to set the value of the text field:
  /// ```dart
  /// onSuggestionSelected: (suggestion) {
  ///   _controller.text = suggestion['name'];
  /// }
  /// ```
  final SuggestionSelectionCallback<T> onSuggestionSelected;

  /// Called for each suggestion returned by [suggestionsCallback] to build the
  /// corresponding widget.
  ///
  /// This callback must not be null. It is called by the TypeAhead widget for
  /// each suggestion, and expected to build a widget to display this
  /// suggestion's info. For example:
  ///
  /// ```dart
  /// itemBuilder: (context, suggestion) {
  ///   return ListTile(
  ///     title: Text(suggestion['name']),
  ///     subtitle: Text('USD' + suggestion['price'].toString())
  ///   );
  /// }
  /// ```
  final ItemBuilder<T> itemBuilder;

  /// used to control the scroll behavior of item-builder list
  final ScrollController? scrollController;

  /// The decoration of the material sheet that contains the suggestions.
  ///
  /// If null, default decoration with an elevation of 4.0 is used
  ///
  final QuickSearchSuggestionsBoxDecoration suggestionsBoxDecoration;

  /// Used to control the `SuggestionsBox`. Allows manual control to
  /// open, close, toggle, or resize the `SuggestionsBox`.
  final QuickSearchSuggestionsBoxController? suggestionsBoxController;

  /// The duration to wait after the user stops typing before calling
  /// [suggestionsCallback]
  ///
  /// This is useful, because, if not set, a request for suggestions will be
  /// sent for every character that the user types.
  ///
  /// This duration is set by default to 300 milliseconds
  final Duration debounceDuration;

  /// Called when waiting for [suggestionsCallback] to return.
  ///
  /// It is expected to return a widget to display while waiting.
  /// For example:
  /// ```dart
  /// (BuildContext context) {
  ///   return Text('Loading...');
  /// }
  /// ```
  ///
  /// If not specified, a [CircularProgressIndicator](https://docs.flutter.io/flutter/material/CircularProgressIndicator-class.html) is shown
  final WidgetBuilder? loadingBuilder;

  /// Called when [suggestionsCallback] returns an empty array.
  ///
  /// It is expected to return a widget to display when no suggestions are
  /// avaiable.
  /// For example:
  /// ```dart
  /// (BuildContext context) {
  ///   return Text('No Items Found!');
  /// }
  /// ```
  ///
  /// If not specified, a simple text is shown
  final WidgetBuilder? noItemsFoundBuilder;

  /// Called when [suggestionsCallback] throws an exception.
  ///
  /// It is called with the error object, and expected to return a widget to
  /// display when an exception is thrown
  /// For example:
  /// ```dart
  /// (BuildContext context, error) {
  ///   return Text('$error');
  /// }
  /// ```
  ///
  /// If not specified, the error is shown in [ThemeData.errorColor](https://docs.flutter.io/flutter/material/ThemeData/errorColor.html)
  final ErrorBuilder? errorBuilder;

  /// Called to display animations when [suggestionsCallback] returns suggestions
  ///
  /// It is provided with the suggestions box instance and the animation
  /// controller, and expected to return some animation that uses the controller
  /// to display the suggestion box.
  ///
  /// For example:
  /// ```dart
  /// transitionBuilder: (context, suggestionsBox, animationController) {
  ///   return FadeTransition(
  ///     child: suggestionsBox,
  ///     opacity: CurvedAnimation(
  ///       parent: animationController,
  ///       curve: Curves.fastOutSlowIn
  ///     ),
  ///   );
  /// }
  /// ```
  /// This argument is best used with [animationDuration] and [animationStart]
  /// to fully control the animation.
  ///
  /// To fully remove the animation, just return `suggestionsBox`
  ///
  /// If not specified, a [SizeTransition](https://docs.flutter.io/flutter/widgets/SizeTransition-class.html) is shown.
  final AnimationTransitionBuilder? transitionBuilder;

  /// The duration that [transitionBuilder] animation takes.
  ///
  /// This argument is best used with [transitionBuilder] and [animationStart]
  /// to fully control the animation.
  ///
  /// Defaults to 500 milliseconds.
  final Duration animationDuration;

  /// Determine the [SuggestionBox]'s direction.
  ///
  /// If [AxisDirection.down], the [SuggestionBox] will be below the [TextField]
  /// and the [_SuggestionsList] will grow **down**.
  ///
  /// If [AxisDirection.up], the [SuggestionBox] will be above the [TextField]
  /// and the [_SuggestionsList] will grow **up**.
  ///
  /// [AxisDirection.left] and [AxisDirection.right] are not allowed.
  final AxisDirection direction;

  /// The value at which the [transitionBuilder] animation starts.
  ///
  /// This argument is best used with [transitionBuilder] and [animationDuration]
  /// to fully control the animation.
  ///
  /// Defaults to 0.25.
  final double animationStart;

  /// The configuration of the [TextField](https://docs.flutter.io/flutter/material/TextField-class.html)
  /// that the TypeAhead widget displays
  final QuickSearchTextFieldConfiguration textFieldConfiguration;

  /// How far below the text field should the suggestions box be
  ///
  /// Defaults to 5.0
  final double suggestionsBoxVerticalOffset;

  /// If set to true, suggestions will be fetched immediately when the field is
  /// added to the view.
  ///
  /// But the suggestions box will only be shown when the field receives focus.
  /// To make the field receive focus immediately, you can set the `autofocus`
  /// property in the [textFieldConfiguration] to true
  ///
  /// Defaults to false
  final bool getImmediateSuggestions;

  /// If set to true, no loading box will be shown while suggestions are
  /// being fetched. [loadingBuilder] will also be ignored.
  ///
  /// Defaults to false.
  final bool hideOnLoading;

  /// If set to true, nothing will be shown if there are no results.
  /// [noItemsFoundBuilder] will also be ignored.
  ///
  /// Defaults to false.
  final bool hideOnEmpty;

  /// If set to true, nothing will be shown if there is an error.
  /// [errorBuilder] will also be ignored.
  ///
  /// Defaults to false.
  final bool hideOnError;

  /// If set to false, the suggestions box will stay opened after
  /// the keyboard is closed.
  ///
  /// Defaults to true.
  final bool hideSuggestionsOnKeyboardHide;

  /// If set to false, the suggestions box will show a circular
  /// progress indicator when retrieving suggestions.
  ///
  /// Defaults to true.
  final bool keepSuggestionsOnLoading;

  /// If set to true, the suggestions box will remain opened even after
  /// selecting a suggestion.
  ///
  /// Note that if this is enabled, the only way
  /// to close the suggestions box is either manually via the
  /// `QuickSearchSuggestionsBoxController` or when the user closes the software
  /// keyboard if `hideSuggestionsOnKeyboardHide` is set to true. Users
  /// with a physical keyboard will be unable to close the
  /// box without a manual way via `QuickSearchSuggestionsBoxController`.
  ///
  /// Defaults to false.
  final bool keepSuggestionsOnSuggestionSelected;

  /// If set to true, in the case where the suggestions box has less than
  /// _SuggestionsBoxController.minOverlaySpace to grow in the desired [direction], the direction axis
  /// will be temporarily flipped if there's more room available in the opposite
  /// direction.
  ///
  /// Defaults to false
  final bool autoFlipDirection;
  final bool hideKeyboard;

  /// The minimum number of characters which must be entered before
  /// [suggestionsCallback] is triggered.
  ///
  /// Defaults to 0.
  final int minCharsForSuggestions;

  /// List button action for suggestion box
  final List<dynamic>? listActionButton;
  final ButtonActionBuilder? actionButtonBuilder;
  final ButtonActionCallback? buttonActionCallback;

  /// Button show all result
  final ButtonActionBuilder? buttonShowAllResult;

  /// Title header recent suggestion box
  final Widget? titleHeaderRecent;

  ///  Widget item recent
  final ItemBuilder<R>? itemRecentBuilder;

  ///  Get all recent callback
  final FetchRecentActionCallback<R>? fetchRecentActionCallback;

  ///  On listen select recent
  final RecentSelectionCallback<R>? onRecentSelected;

  /// Padding button action
  final EdgeInsets? listActionPadding;
  final bool hideSuggestionsBox;

  /// Box decoration search input
  final BoxDecoration? decoration;

  /// Max height search input
  final double? maxHeight;

  /// Check direction text input
  final bool isDirectionRTL;

  ///  Widget contact item
  final ItemBuilder<P>? contactItemBuilder;

  ///  Get all contact callback
  final SuggestionsCallback<P>? contactSuggestionsCallback;

  ///  On listen select contact
  final SuggestionSelectionCallback<P>? onContactSuggestionSelected;

  /// Min input length to start autocomplete
  final int? minInputLengthAutocomplete;

  /// Creates a [TypeAheadFieldQuickSearch]
  const TypeAheadFieldQuickSearch({
    Key? key,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.onSuggestionSelected,
    this.textFieldConfiguration = const QuickSearchTextFieldConfiguration(),
    this.suggestionsBoxDecoration = const QuickSearchSuggestionsBoxDecoration(),
    this.debounceDuration = const Duration(milliseconds: 300),
    this.suggestionsBoxController,
    this.scrollController,
    this.loadingBuilder,
    this.noItemsFoundBuilder,
    this.errorBuilder,
    this.transitionBuilder,
    this.animationStart = 0.25,
    this.animationDuration = const Duration(milliseconds: 500),
    this.getImmediateSuggestions = false,
    this.suggestionsBoxVerticalOffset = 5.0,
    this.direction = AxisDirection.down,
    this.hideOnLoading = false,
    this.hideOnEmpty = false,
    this.hideOnError = false,
    this.hideSuggestionsOnKeyboardHide = true,
    this.keepSuggestionsOnLoading = false,
    this.keepSuggestionsOnSuggestionSelected = false,
    this.autoFlipDirection = false,
    this.hideKeyboard = false,
    this.minCharsForSuggestions = 0,
    this.listActionButton,
    this.actionButtonBuilder,
    this.buttonActionCallback,
    this.buttonShowAllResult,
    this.titleHeaderRecent,
    this.itemRecentBuilder,
    this.fetchRecentActionCallback,
    this.onRecentSelected,
    this.listActionPadding,
    this.hideSuggestionsBox = false,
    this.decoration,
    this.maxHeight,
    this.isDirectionRTL = false,
    this.minInputLengthAutocomplete,
    this.contactItemBuilder,
    this.contactSuggestionsCallback,
    this.onContactSuggestionSelected,
  })  : assert(animationStart >= 0.0 && animationStart <= 1.0),
        assert(
            direction == AxisDirection.down || direction == AxisDirection.up),
        assert(minCharsForSuggestions >= 0),
        super(key: key);

  @override
  State<TypeAheadFieldQuickSearch<T, P, R>> createState() =>
      _TypeAheadFieldQuickSearchState<T, P, R>();
}

class _TypeAheadFieldQuickSearchState<T, P, R>
    extends State<TypeAheadFieldQuickSearch<T, P, R>>
    with WidgetsBindingObserver {
  FocusNode? _focusNode;
  TextEditingController? _textEditingController;
  QuickSearchSuggestionsBox? _suggestionsBox;
  late TextDirection _textDirection;

  TextEditingController? get _effectiveController =>
      widget.textFieldConfiguration.controller ?? _textEditingController;

  FocusNode? get _effectiveFocusNode =>
      widget.textFieldConfiguration.focusNode ?? _focusNode;
  late VoidCallback _focusNodeListener;

  final LayerLink _layerLink = LayerLink();

  // Timer that resizes the suggestion box on each tick. Only active when the user is scrolling.
  Timer? _resizeOnScrollTimer;

  // The rate at which the suggestion box will resize when the user is scrolling
  final Duration _resizeOnScrollRefreshRate = const Duration(milliseconds: 500);

  // Will have a value if the typeahead is inside a scrollable widget
  ScrollPosition? _scrollPosition;

  // Keyboard detection
  final Stream<bool>? _keyboardVisibility =
      (supportedPlatform) ? KeyboardVisibilityController().onChange : null;
  late StreamSubscription<bool>? _keyboardVisibilitySubscription;

  @override
  void didChangeMetrics() {
    // Catch keyboard event and orientation change; resize suggestions list
    _suggestionsBox!.onChangeMetrics();
  }

  @override
  void dispose() {
    _suggestionsBox!.close();
    _suggestionsBox!.widgetMounted = false;
    WidgetsBinding.instance.removeObserver(this);
    _keyboardVisibilitySubscription?.cancel();
    _effectiveFocusNode!.removeListener(_focusNodeListener);
    _focusNode?.dispose();
    _resizeOnScrollTimer?.cancel();
    _scrollPosition?.removeListener(_scrollResizeListener);
    _textEditingController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _textDirection =
        widget.textFieldConfiguration.textDirection ?? TextDirection.ltr;

    if (widget.textFieldConfiguration.controller == null) {
      _textEditingController = TextEditingController();
    }

    if (widget.textFieldConfiguration.focusNode == null) {
      _focusNode = FocusNode();
    }

    _suggestionsBox = QuickSearchSuggestionsBox(
      context,
      widget.direction,
      widget.autoFlipDirection,
      widget.hideSuggestionsBox,
    );
    widget.suggestionsBoxController?.suggestionsBox = _suggestionsBox;
    widget.suggestionsBoxController?.effectiveFocusNode = _effectiveFocusNode;

    _focusNodeListener = () {
      if (_effectiveFocusNode!.hasFocus) {
        _suggestionsBox!.open();
      } else if (widget.hideSuggestionsOnKeyboardHide) {
        _suggestionsBox!.close();
      }
      setState(() {});
    };

    _effectiveFocusNode!.addListener(_focusNodeListener);

    // hide suggestions box on keyboard closed
    _keyboardVisibilitySubscription =
        _keyboardVisibility?.listen((bool isVisible) {
      if (widget.hideSuggestionsOnKeyboardHide && !isVisible) {
        _effectiveFocusNode!.unfocus();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((duration) {
      if (mounted) {
        _initOverlayEntry();
        // calculate initial suggestions list size
        _suggestionsBox!.resize();

        // in case we already missed the focus event
        if (_effectiveFocusNode!.hasFocus) {
          _suggestionsBox!.open();
        }
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scrollableState = Scrollable.maybeOf(context);
    if (scrollableState != null) {
      _scrollPosition = scrollableState.position;
      _scrollPosition!.removeListener(_scrollResizeListener);
      _scrollPosition!.isScrollingNotifier.addListener(_scrollResizeListener);
    }
  }

  void _scrollResizeListener() {
    bool isScrolling = _scrollPosition!.isScrollingNotifier.value;
    _resizeOnScrollTimer?.cancel();
    if (isScrolling) {
      // Scroll started
      _resizeOnScrollTimer =
          Timer.periodic(_resizeOnScrollRefreshRate, (timer) {
        _suggestionsBox!.resize();
      });
    } else {
      // Scroll finished
      _suggestionsBox!.resize();
    }
  }

  void _initOverlayEntry() {
    _suggestionsBox!.overlayEntry = OverlayEntry(builder: (context) {
      final suggestionsList = QuickSearchSuggestionList<T, P, R>(
        suggestionsBox: _suggestionsBox,
        decoration: widget.suggestionsBoxDecoration,
        debounceDuration: widget.debounceDuration,
        controller: _effectiveController,
        loadingBuilder: widget.loadingBuilder,
        scrollController: widget.scrollController,
        noItemsFoundBuilder: widget.noItemsFoundBuilder,
        errorBuilder: widget.errorBuilder,
        transitionBuilder: widget.transitionBuilder,
        suggestionsCallback: widget.suggestionsCallback,
        animationDuration: widget.animationDuration,
        animationStart: widget.animationStart,
        getImmediateSuggestions: widget.getImmediateSuggestions,
        onSuggestionSelected: (T selection) {
          if (!widget.keepSuggestionsOnSuggestionSelected) {
            _effectiveFocusNode!.unfocus();
            _suggestionsBox!.close();
          }
          widget.onSuggestionSelected(selection);
        },
        itemBuilder: widget.itemBuilder,
        direction: _suggestionsBox!.direction,
        hideOnLoading: widget.hideOnLoading,
        hideOnEmpty: widget.hideOnEmpty,
        hideOnError: widget.hideOnError,
        keepSuggestionsOnLoading: widget.keepSuggestionsOnLoading,
        minCharsForSuggestions: widget.minCharsForSuggestions,
        listActionButton: widget.listActionButton,
        actionButtonBuilder: widget.actionButtonBuilder,
        buttonActionCallback: widget.buttonActionCallback,
        buttonShowAllResult: widget.buttonShowAllResult,
        titleHeaderRecent: widget.titleHeaderRecent,
        itemRecentBuilder: widget.itemRecentBuilder,
        fetchRecentActionCallback: widget.fetchRecentActionCallback,
        onRecentSelected: (R selection) {
          if (!widget.keepSuggestionsOnSuggestionSelected) {
            _effectiveFocusNode!.unfocus();
            _suggestionsBox!.close();
          }
          if (widget.onRecentSelected != null) {
            widget.onRecentSelected!(selection);
          }
        },
        listActionPadding: widget.listActionPadding,
        hideSuggestionsBox: widget.hideSuggestionsBox,
        isDirectionRTL: widget.isDirectionRTL,
        minInputLengthAutocomplete: widget.minInputLengthAutocomplete,
        contactSuggestionBuilder: widget.contactItemBuilder,
        contactSuggestionCallback: widget.contactSuggestionsCallback,
        onContactSuggestionSelected: (P selection) {
          if (!widget.keepSuggestionsOnSuggestionSelected) {
            _effectiveFocusNode!.unfocus();
            _suggestionsBox!.close();
          }
          widget.onContactSuggestionSelected?.call(selection);
        },
      );

      double w = _suggestionsBox!.textBoxWidth;
      if (widget.suggestionsBoxDecoration.constraints != null) {
        if (widget.suggestionsBoxDecoration.constraints!.minWidth != 0.0 &&
            widget.suggestionsBoxDecoration.constraints!.maxWidth !=
                double.infinity) {
          w = (widget.suggestionsBoxDecoration.constraints!.minWidth +
                  widget.suggestionsBoxDecoration.constraints!.maxWidth) /
              2;
        } else if (widget.suggestionsBoxDecoration.constraints!.minWidth !=
                0.0 &&
            widget.suggestionsBoxDecoration.constraints!.minWidth > w) {
          w = widget.suggestionsBoxDecoration.constraints!.minWidth;
        } else if (widget.suggestionsBoxDecoration.constraints!.maxWidth !=
                double.infinity &&
            widget.suggestionsBoxDecoration.constraints!.maxWidth < w) {
          w = widget.suggestionsBoxDecoration.constraints!.maxWidth;
        }
      }

      return Positioned(
        width: w,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(
            widget.suggestionsBoxDecoration.offsetX,
            _suggestionsBox!.direction == AxisDirection.down
                ? _suggestionsBox!.textBoxHeight +
                    widget.suggestionsBoxVerticalOffset
                : _suggestionsBox!.directionUpOffset,
          ),
          child: TextFieldTapRegion(
            child: _suggestionsBox!.direction == AxisDirection.down
                ? suggestionsList
                : FractionalTranslation(
                    translation: const Offset(0.0, -1.0),
                    // visually flips list to go up
                    child: suggestionsList,
                  ),
          ),
        ),
      );
    });
  }

  void _onTextChange(String text) {
    final trimmedText = text.trim();
    widget.textFieldConfiguration.onChanged?.call(trimmedText);

    if (trimmedText.isNotEmpty) {
      _updateTextDirection(trimmedText);
    }
  }

  void _updateTextDirection(String text) {
    final directionByText = DirectionUtils.getDirectionByEndsText(text);
    if (directionByText != _textDirection) {
      setState(() {
        _textDirection = directionByText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: _suggestionsBox?.isOpened == true
            ? const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  topLeft: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.colorShadowComposer,
                    blurRadius: 32,
                  ),
                  BoxShadow(
                    color: AppColor.colorShadowComposer,
                    blurRadius: 4,
                  ),
                ],
                color: Colors.white,
              )
            : const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: AppColor.colorBgSearchBar,
              ),
        height: widget.maxHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.textFieldConfiguration.leftButton != null)
              widget.textFieldConfiguration.leftButton!,
            Expanded(
              child: TextField(
                key: widget.textFieldConfiguration.textFieldKey,
                focusNode: _effectiveFocusNode,
                controller: _effectiveController,
                decoration: widget.textFieldConfiguration.decoration,
                style: widget.textFieldConfiguration.style,
                textAlign: widget.textFieldConfiguration.textAlign,
                enabled: widget.textFieldConfiguration.enabled,
                keyboardType: widget.textFieldConfiguration.keyboardType,
                autofocus: widget.textFieldConfiguration.autofocus,
                inputFormatters: widget.textFieldConfiguration.inputFormatters,
                autocorrect: widget.textFieldConfiguration.autocorrect,
                maxLines: widget.textFieldConfiguration.maxLines,
                textAlignVertical:
                    widget.textFieldConfiguration.textAlignVertical,
                minLines: widget.textFieldConfiguration.minLines,
                maxLength: widget.textFieldConfiguration.maxLength,
                maxLengthEnforcement:
                    widget.textFieldConfiguration.maxLengthEnforcement,
                obscureText: widget.textFieldConfiguration.obscureText,
                onChanged: _onTextChange,
                onSubmitted: widget.textFieldConfiguration.onSubmitted,
                onEditingComplete:
                    widget.textFieldConfiguration.onEditingComplete,
                onTap: widget.textFieldConfiguration.onTap,
                scrollPadding: widget.textFieldConfiguration.scrollPadding,
                textInputAction: widget.textFieldConfiguration.textInputAction,
                textCapitalization:
                    widget.textFieldConfiguration.textCapitalization,
                keyboardAppearance:
                    widget.textFieldConfiguration.keyboardAppearance,
                cursorWidth: widget.textFieldConfiguration.cursorWidth,
                cursorRadius: widget.textFieldConfiguration.cursorRadius,
                cursorColor: widget.textFieldConfiguration.cursorColor,
                textDirection: _textDirection,
                enableInteractiveSelection:
                    widget.textFieldConfiguration.enableInteractiveSelection,
                readOnly: widget.hideKeyboard,
              ),
            ),
            if (widget.textFieldConfiguration.clearTextButton != null &&
                _effectiveController?.text.isNotEmpty == true)
              widget.textFieldConfiguration.clearTextButton!,
            if (widget.textFieldConfiguration.rightButton != null)
              widget.textFieldConfiguration.rightButton!,
          ],
        ),
      ),
    );
  }
}
