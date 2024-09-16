
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

typedef SuggestionsCallback<T> = FutureOr<List<T>> Function(String pattern);
typedef FetchRecentActionCallback<R> = FutureOr<List<R>> Function(String pattern);
typedef ItemBuilder<T> = Widget Function(BuildContext context, T itemData);
typedef SuggestionSelectionCallback<T> = void Function(T suggestion);
typedef RecentSelectionCallback<R> = void Function(R recent);
typedef ErrorBuilder = Widget Function(BuildContext context, Object? error);
typedef ButtonActionBuilder = Widget Function(BuildContext context, dynamic action);
typedef ButtonActionCallback = void Function(dynamic action);

typedef AnimationTransitionBuilder = Widget Function(
    BuildContext context, Widget child, AnimationController? controller);

final supportedPlatform = (kIsWeb || Platform.isAndroid || Platform.isIOS);

/// A [FormField](https://docs.flutter.io/flutter/widgets/FormField-class.html)
/// implementation of [TypeAheadFieldQuickSearch], that allows the value to be saved,
/// validated, etc.
///
/// See also:
///
/// * [TypeAheadFieldQuickSearch], A [TextField](https://docs.flutter.io/flutter/material/TextField-class.html)
/// that displays a list of suggestions as the user types
class QuickSearchInputForm<T, P, R> extends FormField<String> {
  /// The configuration of the [TextField](https://docs.flutter.io/flutter/material/TextField-class.html)
  /// that the TypeAhead widget displays
  final QuickSearchTextFieldConfiguration textFieldConfiguration;

  /// Creates a [QuickSearchInputForm]
  QuickSearchInputForm(
      {Key? key,
        String? initialValue,
        bool getImmediateSuggestions = false,
        bool enabled = true,
        AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
        FormFieldSetter<String>? onSaved,
        FormFieldValidator<String>? validator,
        ErrorBuilder? errorBuilder,
        WidgetBuilder? noItemsFoundBuilder,
        WidgetBuilder? loadingBuilder,
        Duration debounceDuration = const Duration(milliseconds: 300),
        QuickSearchSuggestionsBoxDecoration suggestionsBoxDecoration =
        const QuickSearchSuggestionsBoxDecoration(),
        QuickSearchSuggestionsBoxController? suggestionsBoxController,
        required SuggestionSelectionCallback<T> onSuggestionSelected,
        required ItemBuilder<T> itemBuilder,
        required SuggestionsCallback<T> suggestionsCallback,
        double suggestionsBoxVerticalOffset = 5.0,
        this.textFieldConfiguration = const QuickSearchTextFieldConfiguration(),
        AnimationTransitionBuilder? transitionBuilder,
        Duration animationDuration = const Duration(milliseconds: 500),
        double animationStart = 0.25,
        AxisDirection direction = AxisDirection.down,
        bool hideOnLoading = false,
        bool hideOnEmpty = false,
        bool hideOnError = false,
        bool hideSuggestionsOnKeyboardHide = true,
        bool keepSuggestionsOnLoading = true,
        bool keepSuggestionsOnSuggestionSelected = false,
        bool autoFlipDirection = false,
        bool hideKeyboard = false,
        int minCharsForSuggestions = 0,
        List<dynamic>? listActionButton,
        ButtonActionBuilder? actionButtonBuilder,
        ButtonActionCallback? buttonActionCallback,
        ButtonActionBuilder? buttonShowAllResult,
        Widget? titleHeaderRecent,
        ItemBuilder<R>? itemRecentBuilder,
        FetchRecentActionCallback<R>? fetchRecentActionCallback,
        RecentSelectionCallback<R>? onRecentSelected,
        EdgeInsets? listActionPadding,
        bool hideSuggestionsBox = false,
        BoxDecoration? decoration,
        double? maxHeight,
        bool isDirectionRTL = false,
        ItemBuilder<P>? contactItemBuilder,
        SuggestionsCallback<P>? contactSuggestionsCallback,
        SuggestionSelectionCallback<P>? onContactSuggestionSelected,
      }) : assert(
  initialValue == null || textFieldConfiguration.controller == null),
        assert(minCharsForSuggestions >= 0),
        super(
          key: key,
          onSaved: onSaved,
          validator: validator,
          initialValue: textFieldConfiguration.controller != null
              ? textFieldConfiguration.controller!.text
              : (initialValue ?? ''),
          enabled: enabled,
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<String> field) {
            final _TypeAheadFormFieldState state =
            field as _TypeAheadFormFieldState<dynamic, dynamic, dynamic>;

            return TypeAheadFieldQuickSearch(
              getImmediateSuggestions: getImmediateSuggestions,
              transitionBuilder: transitionBuilder,
              errorBuilder: errorBuilder,
              noItemsFoundBuilder: noItemsFoundBuilder,
              loadingBuilder: loadingBuilder,
              debounceDuration: debounceDuration,
              suggestionsBoxDecoration: suggestionsBoxDecoration,
              suggestionsBoxController: suggestionsBoxController,
              textFieldConfiguration: textFieldConfiguration.copyWith(
                decoration: textFieldConfiguration.decoration
                    .copyWith(errorText: state.errorText),
                onChanged: (text) {
                  state.didChange(text);
                  textFieldConfiguration.onChanged?.call(text);
                },
                controller: state._effectiveController,
              ),
              suggestionsBoxVerticalOffset: suggestionsBoxVerticalOffset,
              onSuggestionSelected: onSuggestionSelected,
              itemBuilder: itemBuilder,
              suggestionsCallback: suggestionsCallback,
              animationStart: animationStart,
              animationDuration: animationDuration,
              direction: direction,
              hideOnLoading: hideOnLoading,
              hideOnEmpty: hideOnEmpty,
              hideOnError: hideOnError,
              hideSuggestionsOnKeyboardHide: hideSuggestionsOnKeyboardHide,
              keepSuggestionsOnLoading: keepSuggestionsOnLoading,
              keepSuggestionsOnSuggestionSelected:
              keepSuggestionsOnSuggestionSelected,
              autoFlipDirection: autoFlipDirection,
              hideKeyboard: hideKeyboard,
              minCharsForSuggestions: minCharsForSuggestions,
              listActionButton: listActionButton,
              actionButtonBuilder: actionButtonBuilder,
              buttonActionCallback: buttonActionCallback,
              buttonShowAllResult: buttonShowAllResult,
              titleHeaderRecent: titleHeaderRecent,
              itemRecentBuilder: itemRecentBuilder,
              fetchRecentActionCallback: fetchRecentActionCallback,
              onRecentSelected: onRecentSelected,
              listActionPadding: listActionPadding,
              hideSuggestionsBox: hideSuggestionsBox,
              decoration: decoration,
              maxHeight: maxHeight,
              isDirectionRTL: isDirectionRTL,
              contactItemBuilder: contactItemBuilder,
              contactSuggestionsCallback: contactSuggestionsCallback,
              onContactSuggestionSelected: onContactSuggestionSelected,
            );
          });

  @override
  FormFieldState<String> createState() => _TypeAheadFormFieldState<T, P, R>();
}

class _TypeAheadFormFieldState<T, P, R> extends FormFieldState<String> {
  TextEditingController? _controller;

  TextEditingController? get _effectiveController =>
      widget.textFieldConfiguration.controller ?? _controller;

  @override
  QuickSearchInputForm get widget => super.widget as QuickSearchInputForm<dynamic, dynamic, dynamic>;

  @override
  void initState() {
    super.initState();
    if (widget.textFieldConfiguration.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    } else {
      widget.textFieldConfiguration.controller!
          .addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(QuickSearchInputForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.textFieldConfiguration.controller !=
        oldWidget.textFieldConfiguration.controller) {
      oldWidget.textFieldConfiguration.controller
          ?.removeListener(_handleControllerChanged);
      widget.textFieldConfiguration.controller
          ?.addListener(_handleControllerChanged);

      if (oldWidget.textFieldConfiguration.controller != null &&
          widget.textFieldConfiguration.controller == null) {
        _controller = TextEditingController.fromValue(
            oldWidget.textFieldConfiguration.controller!.value);
      }
      if (widget.textFieldConfiguration.controller != null) {
        setValue(widget.textFieldConfiguration.controller!.text);
        if (oldWidget.textFieldConfiguration.controller == null) {
          _controller = null;
        }
      }
    }
  }

  @override
  void dispose() {
    widget.textFieldConfiguration.controller
        ?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveController!.text = widget.initialValue!;
    });
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController!.text != value) {
      didChange(_effectiveController!.text);
    }
  }
}

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

  /// Used to control the `_SuggestionsBox`. Allows manual control to
  /// open, close, toggle, or resize the `_SuggestionsBox`.
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

  /// Creates a [TypeAheadFieldQuickSearch]
  const TypeAheadFieldQuickSearch(
      {Key? key,
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
        this.keepSuggestionsOnLoading = true,
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
        this.contactItemBuilder,
        this.contactSuggestionsCallback,
        this.onContactSuggestionSelected,
      }) : assert(animationStart >= 0.0 && animationStart <= 1.0),
        assert(
        direction == AxisDirection.down || direction == AxisDirection.up),
        assert(minCharsForSuggestions >= 0),
        super(key: key);

  @override
  State<TypeAheadFieldQuickSearch<T, P, R>> createState() => _TypeAheadFieldQuickSearchState<T, P, R>();
}

class _TypeAheadFieldQuickSearchState<T, P, R> extends State<TypeAheadFieldQuickSearch<T, P, R>>
    with WidgetsBindingObserver {
  FocusNode? _focusNode;
  TextEditingController? _textEditingController;
  _SuggestionsBox? _suggestionsBox;
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

    _textDirection = widget.textFieldConfiguration.textDirection ?? TextDirection.ltr;

    if (widget.textFieldConfiguration.controller == null) {
      _textEditingController = TextEditingController();
    }

    if (widget.textFieldConfiguration.focusNode == null) {
      _focusNode = FocusNode();
    }

    _suggestionsBox = _SuggestionsBox(
        context,
        widget.direction,
        widget.autoFlipDirection,
        widget.hideSuggestionsBox);
    widget.suggestionsBoxController?._suggestionsBox = _suggestionsBox;
    widget.suggestionsBoxController?._effectiveFocusNode =
        _effectiveFocusNode;

    _focusNodeListener = () {
      if (_effectiveFocusNode!.hasFocus) {
        _suggestionsBox!.open();
      } else {
        if (widget.hideSuggestionsOnKeyboardHide){
          _suggestionsBox!.close();
        }
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
    _suggestionsBox!._overlayEntry = OverlayEntry(builder: (context) {
      final suggestionsList = _SuggestionsList<T, P, R>(
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
                  ? _suggestionsBox!.textBoxHeight + widget.suggestionsBoxVerticalOffset
                  : _suggestionsBox!.directionUpOffset),
          child: TextFieldTapRegion(
            child: _suggestionsBox!.direction == AxisDirection.down
              ? suggestionsList
              : FractionalTranslation(
                  translation: const Offset(0.0, -1.0), // visually flips list to go up
                  child: suggestionsList,
                )
          ),
        ),
      );
    });
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
                  topLeft: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                    color: AppColor.colorShadowComposer,
                    blurRadius: 32),
                BoxShadow(
                    color: AppColor.colorShadowComposer,
                    blurRadius: 4),
              ],
              color: Colors.white)
          : const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: AppColor.colorBgSearchBar),
        height: widget.maxHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.textFieldConfiguration.leftButton != null)
              widget.textFieldConfiguration.leftButton!,
            Expanded(
              child: TextField(
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
                textAlignVertical: widget.textFieldConfiguration.textAlignVertical,
                minLines: widget.textFieldConfiguration.minLines,
                maxLength: widget.textFieldConfiguration.maxLength,
                maxLengthEnforcement: widget.textFieldConfiguration.maxLengthEnforcement,
                obscureText: widget.textFieldConfiguration.obscureText,
                onChanged: (input) {
                  widget.textFieldConfiguration.onChanged?.call(input);
                  if (input.isNotEmpty) {
                    final directionByText = DirectionUtils.getDirectionByEndsText(input);
                    if (directionByText != _textDirection) {
                      setState(() {
                        _textDirection = directionByText;
                      });
                    }
                  }
                },
                onSubmitted: widget.textFieldConfiguration.onSubmitted,
                onEditingComplete: widget.textFieldConfiguration.onEditingComplete,
                onTap: widget.textFieldConfiguration.onTap,
                scrollPadding: widget.textFieldConfiguration.scrollPadding,
                textInputAction: widget.textFieldConfiguration.textInputAction,
                textCapitalization: widget.textFieldConfiguration.textCapitalization,
                keyboardAppearance: widget.textFieldConfiguration.keyboardAppearance,
                cursorWidth: widget.textFieldConfiguration.cursorWidth,
                cursorRadius: widget.textFieldConfiguration.cursorRadius,
                cursorColor: widget.textFieldConfiguration.cursorColor,
                textDirection: _textDirection,
                enableInteractiveSelection: widget.textFieldConfiguration.enableInteractiveSelection,
                readOnly: widget.hideKeyboard,
              ),
            ),
            if (widget.textFieldConfiguration.clearTextButton != null
                && _effectiveController?.text.isNotEmpty == true)
              widget.textFieldConfiguration.clearTextButton!,
            if (widget.textFieldConfiguration.rightButton != null)
              widget.textFieldConfiguration.rightButton!,
          ],
        ),
      ),
    );
  }
}

class _SuggestionsList<T, P, R> extends StatefulWidget {
  final _SuggestionsBox? suggestionsBox;
  final TextEditingController? controller;
  final bool getImmediateSuggestions;
  final SuggestionSelectionCallback<T>? onSuggestionSelected;
  final SuggestionsCallback<T>? suggestionsCallback;
  final ItemBuilder<T>? itemBuilder;
  final ScrollController? scrollController;
  final QuickSearchSuggestionsBoxDecoration? decoration;
  final Duration? debounceDuration;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? noItemsFoundBuilder;
  final ErrorBuilder? errorBuilder;
  final AnimationTransitionBuilder? transitionBuilder;
  final Duration? animationDuration;
  final double? animationStart;
  final AxisDirection? direction;
  final bool? hideOnLoading;
  final bool? hideOnEmpty;
  final bool? hideOnError;
  final bool? keepSuggestionsOnLoading;
  final int? minCharsForSuggestions;
  final List<dynamic>? listActionButton;
  final ButtonActionBuilder? actionButtonBuilder;
  final ButtonActionCallback? buttonActionCallback;
  final ButtonActionBuilder? buttonShowAllResult;
  final Widget? titleHeaderRecent;
  final ItemBuilder<R>? itemRecentBuilder;
  final FetchRecentActionCallback<R>? fetchRecentActionCallback;
  final RecentSelectionCallback<R>? onRecentSelected;
  final EdgeInsets? listActionPadding;
  final bool hideSuggestionsBox;
  final bool isDirectionRTL;
  final ItemBuilder<P>? contactSuggestionBuilder;
  final SuggestionsCallback<P>? contactSuggestionCallback;
  final SuggestionSelectionCallback<P>? onContactSuggestionSelected;

  const _SuggestionsList({
    required this.suggestionsBox,
    this.controller,
    this.getImmediateSuggestions = false,
    this.onSuggestionSelected,
    this.suggestionsCallback,
    this.itemBuilder,
    this.scrollController,
    this.decoration,
    this.debounceDuration,
    this.loadingBuilder,
    this.noItemsFoundBuilder,
    this.errorBuilder,
    this.transitionBuilder,
    this.animationDuration,
    this.animationStart,
    this.direction,
    this.hideOnLoading,
    this.hideOnEmpty,
    this.hideOnError,
    this.keepSuggestionsOnLoading,
    this.minCharsForSuggestions,
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
    this.isDirectionRTL = false,
    this.contactSuggestionBuilder,
    this.contactSuggestionCallback,
    this.onContactSuggestionSelected,
  });

  @override
  _SuggestionsListState<T, P, R> createState() => _SuggestionsListState<T, P, R>();
}

class _SuggestionsListState<T, P, R> extends State<_SuggestionsList<T, P, R>>
    with SingleTickerProviderStateMixin {
  Iterable<T>? _suggestions;
  Iterable<R>? _recentItems;
  Iterable<P>? _contacts;
  late bool _suggestionsValid;
  late VoidCallback _controllerListener;
  Timer? _debounceTimer;
  bool? _isLoading, _isQueued;
  AnimationController? _animationController;
  String? _lastTextValue;
  late final ScrollController _scrollController =
      widget.scrollController ?? ScrollController();

  _SuggestionsListState() {
    _controllerListener = () async {
      // If we came here because of a change in selected text, not because of
      // actual change in text
      if (widget.controller!.text == _lastTextValue) return;

      _lastTextValue = widget.controller!.text;

      _debounceTimer?.cancel();
      if (widget.controller!.text.length <= widget.minCharsForSuggestions!) {
        if (mounted) {
          Iterable<R>? recentItems;
          try {
            if (widget.fetchRecentActionCallback != null) {
              recentItems = await widget.fetchRecentActionCallback!(widget.controller!.text);
            }
          } catch (e) {
            logError('_SuggestionsListState::_SuggestionsListState(): $e');
          }

          setState(() {
            _isLoading = false;
            _suggestions = null;
            _contacts = null;
            _recentItems = recentItems;
            _suggestionsValid = true;
          });
        }
        return;
      } else {
        _debounceTimer = Timer(widget.debounceDuration!, () async {
          if (_debounceTimer!.isActive) return;
          if (_isLoading!) {
            _isQueued = true;
            return;
          }

          await invalidateSuggestions();
          while (_isQueued!) {
            _isQueued = false;
            await invalidateSuggestions();
          }
        });
      }
    };
  }

  @override
  void didUpdateWidget(_SuggestionsList<T, P, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller!.addListener(_controllerListener);
    _getSuggestions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getSuggestions();
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _suggestionsValid = widget.minCharsForSuggestions! > 0 ? true : false;
    _isLoading = false;
    _isQueued = false;
    _lastTextValue = widget.controller!.text;

    if (widget.getImmediateSuggestions) {
      _getSuggestions();
    }

    widget.controller!.addListener(_controllerListener);
  }

  Future<void> invalidateSuggestions() async {
    if (widget.hideSuggestionsBox) return;
    _suggestionsValid = false;
    await _getSuggestions();
  }

  Future<void> _getSuggestions() async {
    if (_suggestionsValid || widget.hideSuggestionsBox) return;
    _suggestionsValid = true;

    if (mounted) {
      setState(() {
        _animationController!.forward(from: 1.0);

        _isLoading = true;
      });

      Iterable<T>? suggestions;
      Iterable<R>? recentItems;
      Iterable<P>? contacts;
      Object? error;

      try {
        suggestions = await widget.suggestionsCallback!(widget.controller!.text);
        if (widget.fetchRecentActionCallback != null) {
          recentItems = await widget.fetchRecentActionCallback!(widget.controller!.text);
        }
        if (widget.contactSuggestionCallback != null) {
          contacts = await widget.contactSuggestionCallback!(widget.controller!.text);
        }
      } catch (e) {
        error = e;
      }

      if (mounted) {
        // if it wasn't removed in the meantime
        setState(() {
          double? animationStart = widget.animationStart;
          // allow suggestionsCallback to return null and not throw error here
          if (error != null || suggestions?.isEmpty == true) {
            animationStart = 1.0;
          }
          _animationController!.forward(from: animationStart);

          _isLoading = false;
          _suggestions = suggestions;
          _recentItems = recentItems;
          _contacts = contacts;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hideSuggestionsBox) {
      return const SizedBox.shrink();
    }

    Widget child;

    if ((_suggestions?.isNotEmpty == true || _contacts?.isNotEmpty == true) && widget.controller?.text.isNotEmpty == true) {
      child = createSuggestionsWidget();
    } else {
      child = createRecentWidget();
    }

    final animationChild = widget.transitionBuilder != null
        ? widget.transitionBuilder!(context, child, _animationController)
        : SizeTransition(
            axisAlignment: -1.0,
            sizeFactor: CurvedAnimation(
                parent: _animationController!,
                curve: Curves.fastOutSlowIn),
            child: child,
          );

    BoxConstraints constraints;
    if (widget.decoration!.constraints == null) {
      constraints = BoxConstraints(
        maxHeight: widget.suggestionsBox!.maxHeight,
      );
    } else {
      double maxHeight = min(widget.decoration!.constraints!.maxHeight,
          widget.suggestionsBox!.maxHeight);
      constraints = widget.decoration!.constraints!.copyWith(
        minHeight: min(widget.decoration!.constraints!.minHeight, maxHeight),
        maxHeight: maxHeight,
      );
    }

    var container = Material(
      elevation: widget.suggestionsBox?.isOpened == true
        ? 1
        : widget.decoration!.elevation,
      color: widget.decoration!.color,
      shape: widget.decoration!.shape,
      borderRadius:  widget.suggestionsBox?.isOpened == true
        ? const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16))
        : widget.decoration!.borderRadius,
      shadowColor: widget.decoration!.shadowColor,
      clipBehavior: widget.decoration!.clipBehavior,
      child: ConstrainedBox(
        constraints: constraints,
        child: animationChild,
      ),
    );

    return PointerInterceptor(child: container);
  }

  Widget createSuggestionsWidget() {
    final listItemSuggestionWidget = _buildListViewSuggestionWidget();
    final loadingWidget = _buildLoadingBarWidget();
    final listActionWidget = _buildListActionWidget();
    final listItemContactWidget = _buildListViewContactWidget();

    Widget child = ListView(
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      controller: _scrollController,
      reverse: widget.suggestionsBox!.direction == AxisDirection.down ? false : true, // reverses the list to start at the bottom
      children: [
        if (listActionWidget != null) listActionWidget,
        if (loadingWidget != null) loadingWidget,
        if (widget.buttonShowAllResult != null && widget.controller?.text.isNotEmpty == true)
          widget.buttonShowAllResult!(context, widget.controller?.text),
        if (listItemContactWidget.isNotEmpty)
          ... listItemContactWidget,
        if (listItemContactWidget.isNotEmpty && listItemSuggestionWidget.isNotEmpty)
          const Divider(),
        if (listItemSuggestionWidget.isNotEmpty)
          ... [
            ... listItemSuggestionWidget,
            const SizedBox(height: 16)
          ],
      ],
    );

    if (widget.decoration!.hasScrollbar) {
      child = Scrollbar(
        controller: _scrollController,
        child: child,
      );
    }

    return child;
  }

  Widget createRecentWidget() {
    final listItemRecent = _buildListViewRecentWidget();
    final loadingWidget = _buildLoadingBarWidget();
    final listActionWidget = _buildListActionWidget();

    Widget child = ListView(
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      controller: _scrollController,
      reverse: widget.suggestionsBox!.direction == AxisDirection.down ? false : true, // reverses the list to start at the bottom
      children: [
        if (listActionWidget != null) listActionWidget,
        if (loadingWidget != null) loadingWidget,
        if (widget.buttonShowAllResult != null && widget.controller?.text.isNotEmpty == true)
          widget.buttonShowAllResult!(context, widget.controller?.text),
        if (_recentItems?.isNotEmpty == true && widget.itemRecentBuilder != null && widget.titleHeaderRecent != null)
          widget.titleHeaderRecent!,
        if (listItemRecent.isNotEmpty)
          ... [
            ... listItemRecent,
            const SizedBox(height: 16)
          ],
      ],
    );

    if (widget.decoration!.hasScrollbar) {
      child = Scrollbar(
        controller: _scrollController,
        child: Container(child: child),
      );
    }

    return child;
  }


  Widget? _buildListActionWidget() {
    if (widget.listActionButton?.isNotEmpty != true
        || widget.actionButtonBuilder == null) {
      return null;
    }

    final listActionWidget = Wrap(children: widget.listActionButton!
        .map((action) {
      if (widget.buttonActionCallback != null) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 8, bottom: 8),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              onTap: () {
                widget.buttonActionCallback?.call(action);
                invalidateSuggestions();
              },
              child: widget.actionButtonBuilder!(context, action),
            ),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 8, bottom: 8),
          child: widget.actionButtonBuilder!(context, action)
        );
      }
    })
        .toList()
    );

    if (widget.listActionPadding != null) {
      return Padding(padding: widget.listActionPadding!, child: listActionWidget);
    } else {
      return listActionWidget;
    }
  }

  Widget? _buildLoadingBarWidget() {
    if (_isLoading != true
        || widget.hideOnLoading != false
        || widget.keepSuggestionsOnLoading != false) {
      return null;
    }

    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context);
    } else {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  List<Widget> _buildListViewRecentWidget() {
    if (_recentItems?.isNotEmpty != true || widget.itemRecentBuilder == null) {
      return [];
    }

    return _recentItems!
      .map((recent) {
        if (widget.onRecentSelected != null) {
          return InkWell(
            child: widget.itemRecentBuilder!(context, recent),
            onTap: () => widget.onRecentSelected!(recent),
          );
        } else {
          return widget.itemRecentBuilder!(context, recent);
        }
      })
      .toList();
  }

  List<Widget> _buildListViewSuggestionWidget() {
    if (_suggestions?.isNotEmpty != true || widget.itemBuilder == null) {
      return [];
    }

    return _suggestions!
      .map((suggestion) {
        if (widget.onSuggestionSelected != null) {
          return InkWell(
            child: widget.itemBuilder!(context, suggestion),
            onTap: () => widget.onSuggestionSelected?.call(suggestion),
          );
        } else {
          return widget.itemBuilder!(context, suggestion);
        }
      })
      .toList();
  }

  List<Widget> _buildListViewContactWidget() {
    if (_contacts?.isNotEmpty != true || widget.contactSuggestionBuilder == null) {
      return [];
    }

    return _contacts!
      .map((contact) {
        if (widget.onContactSuggestionSelected != null) {
          return InkWell(
            child: widget.contactSuggestionBuilder!(context, contact),
            onTap: () => widget.onContactSuggestionSelected?.call(contact),
          );
        } else {
          return widget.contactSuggestionBuilder!(context, contact);
        }
      })
      .toList();
  }
}

/// Supply an instance of this class to the [TypeAhead.suggestionsBoxDecoration]
/// property to configure the suggestions box decoration
class QuickSearchSuggestionsBoxDecoration {
  /// The z-coordinate at which to place the suggestions box. This controls the size
  /// of the shadow below the box.
  ///
  /// Same as [Material.elevation](https://docs.flutter.io/flutter/material/Material/elevation.html)
  final double elevation;

  /// The color to paint the suggestions box.
  ///
  /// Same as [Material.color](https://docs.flutter.io/flutter/material/Material/color.html)
  final Color? color;

  /// Defines the material's shape as well its shadow.
  ///
  /// Same as [Material.shape](https://docs.flutter.io/flutter/material/Material/shape.html)
  final ShapeBorder? shape;

  /// Defines if a scrollbar will be displayed or not.
  final bool hasScrollbar;

  /// If non-null, the corners of this box are rounded by this [BorderRadius](https://docs.flutter.io/flutter/painting/BorderRadius-class.html).
  ///
  /// Same as [Material.borderRadius](https://docs.flutter.io/flutter/material/Material/borderRadius.html)
  final BorderRadius? borderRadius;

  /// The color to paint the shadow below the material.
  ///
  /// Same as [Material.shadowColor](https://docs.flutter.io/flutter/material/Material/shadowColor.html)
  final Color shadowColor;

  /// The constraints to be applied to the suggestions box
  final BoxConstraints? constraints;

  /// Adds an offset to the suggestions box
  final double offsetX;

  /// The content will be clipped (or not) according to this option.
  ///
  /// Same as [Material.clipBehavior](https://api.flutter.dev/flutter/material/Material/clipBehavior.html)
  final Clip clipBehavior;

  /// Creates a QuickSearchSuggestionsBoxDecoration
  const QuickSearchSuggestionsBoxDecoration(
      {this.elevation = 4.0,
        this.color,
        this.shape,
        this.hasScrollbar = true,
        this.borderRadius,
        this.shadowColor = const Color(0xFF000000),
        this.constraints,
        this.clipBehavior = Clip.none,
        this.offsetX = 0.0});
}

/// Supply an instance of this class to the [TypeAhead.textFieldConfiguration]
/// property to configure the displayed text field
class QuickSearchTextFieldConfiguration {
  /// The decoration to show around the text field.
  ///
  /// Same as [TextField.decoration](https://docs.flutter.io/flutter/material/TextField/decoration.html)
  final InputDecoration decoration;

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController](https://docs.flutter.io/flutter/widgets/TextEditingController-class.html).
  /// A typical use case for this field in the TypeAhead widget is to set the
  /// text of the widget when a suggestion is selected. For example:
  ///
  /// ```dart
  /// final _controller = TextEditingController();
  /// ...
  /// ...
  /// TypeAheadFieldQuickSearch(
  ///   controller: _controller,
  ///   ...
  ///   ...
  ///   onSuggestionSelected: (suggestion) {
  ///     _controller.text = suggestion['city_name'];
  ///   }
  /// )
  /// ```
  final TextEditingController? controller;

  /// Controls whether this widget has keyboard focus.
  ///
  /// Same as [TextField.focusNode](https://docs.flutter.io/flutter/material/TextField/focusNode.html)
  final FocusNode? focusNode;

  /// The style to use for the text being edited.
  ///
  /// Same as [TextField.style](https://docs.flutter.io/flutter/material/TextField/style.html)
  final TextStyle? style;

  /// How the text being edited should be aligned horizontally.
  ///
  /// Same as [TextField.textAlign](https://docs.flutter.io/flutter/material/TextField/textAlign.html)
  final TextAlign textAlign;

  /// Same as [TextField.textDirection](https://docs.flutter.io/flutter/material/TextField/textDirection.html)
  ///
  /// Defaults to null
  final TextDirection? textDirection;

  /// Same as [TextField.textAlignVertical](https://api.flutter.dev/flutter/material/TextField/textAlignVertical.html)
  final TextAlignVertical? textAlignVertical;

  /// If false the textfield is "disabled": it ignores taps and its
  /// [decoration] is rendered in grey.
  ///
  /// Same as [TextField.enabled](https://docs.flutter.io/flutter/material/TextField/enabled.html)
  final bool enabled;

  /// Whether to show input suggestions as the user types.
  ///
  /// Same as [TextField.enableSuggestions](https://api.flutter.dev/flutter/material/TextField/enableSuggestions.html)
  final bool enableSuggestions;

  /// The type of keyboard to use for editing the text.
  ///
  /// Same as [TextField.keyboardType](https://docs.flutter.io/flutter/material/TextField/keyboardType.html)
  final TextInputType keyboardType;

  /// Whether this text field should focus itself if nothing else is already
  /// focused.
  ///
  /// Same as [TextField.autofocus](https://docs.flutter.io/flutter/material/TextField/autofocus.html)
  final bool autofocus;

  /// Optional input validation and formatting overrides.
  ///
  /// Same as [TextField.inputFormatters](https://docs.flutter.io/flutter/material/TextField/inputFormatters.html)
  final List<TextInputFormatter>? inputFormatters;

  /// Whether to enable autocorrection.
  ///
  /// Same as [TextField.autocorrect](https://docs.flutter.io/flutter/material/TextField/autocorrect.html)
  final bool autocorrect;

  /// The maximum number of lines for the text to span, wrapping if necessary.
  ///
  /// Same as [TextField.maxLines](https://docs.flutter.io/flutter/material/TextField/maxLines.html)
  final int? maxLines;

  /// The minimum number of lines to occupy when the content spans fewer lines.
  ///
  /// Same as [TextField.minLines](https://docs.flutter.io/flutter/material/TextField/minLines.html)
  final int? minLines;

  /// The maximum number of characters (Unicode scalar values) to allow in the
  /// text field.
  ///
  /// Same as [TextField.maxLength](https://docs.flutter.io/flutter/material/TextField/maxLength.html)
  final int? maxLength;

  /// If true, prevents the field from allowing more than [maxLength]
  /// characters.
  ///
  /// Same as [TextField.maxLengthEnforcement](https://api.flutter.dev/flutter/material/TextField/maxLengthEnforcement.html)
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// Whether to hide the text being edited (e.g., for passwords).
  ///
  /// Same as [TextField.obscureText](https://docs.flutter.io/flutter/material/TextField/obscureText.html)
  final bool obscureText;

  /// Called when the text being edited changes.
  ///
  /// Same as [TextField.onChanged](https://docs.flutter.io/flutter/material/TextField/onChanged.html)
  final ValueChanged<String>? onChanged;

  /// Called when the user indicates that they are done editing the text in the
  /// field.
  ///
  /// Same as [TextField.onSubmitted](https://docs.flutter.io/flutter/material/TextField/onSubmitted.html)
  final ValueChanged<String>? onSubmitted;

  /// The color to use when painting the cursor.
  ///
  /// Same as [TextField.cursorColor](https://docs.flutter.io/flutter/material/TextField/cursorColor.html)
  final Color? cursorColor;

  /// How rounded the corners of the cursor should be. By default, the cursor has a null Radius
  ///
  /// Same as [TextField.cursorRadius](https://docs.flutter.io/flutter/material/TextField/cursorRadius.html)
  final Radius? cursorRadius;

  /// How thick the cursor will be.
  ///
  /// Same as [TextField.cursorWidth](https://docs.flutter.io/flutter/material/TextField/cursorWidth.html)
  final double cursorWidth;

  /// The appearance of the keyboard.
  ///
  /// Same as [TextField.keyboardAppearance](https://docs.flutter.io/flutter/material/TextField/keyboardAppearance.html)
  final Brightness? keyboardAppearance;

  /// Called when the user submits editable content (e.g., user presses the "done" button on the keyboard).
  ///
  /// Same as [TextField.onEditingComplete](https://docs.flutter.io/flutter/material/TextField/onEditingComplete.html)
  final VoidCallback? onEditingComplete;

  /// Called for each distinct tap except for every second tap of a double tap.
  ///
  /// Same as [TextField.onTap](https://docs.flutter.io/flutter/material/TextField/onTap.html)
  final GestureTapCallback? onTap;

  /// Configures padding to edges surrounding a Scrollable when the Textfield scrolls into view.
  ///
  /// Same as [TextField.scrollPadding](https://docs.flutter.io/flutter/material/TextField/scrollPadding.html)
  final EdgeInsets scrollPadding;

  /// Configures how the platform keyboard will select an uppercase or lowercase keyboard.
  ///
  /// Same as [TextField.TextCapitalization](https://docs.flutter.io/flutter/material/TextField/textCapitalization.html)
  final TextCapitalization textCapitalization;

  /// The type of action button to use for the keyboard.
  ///
  /// Same as [TextField.textInputAction](https://docs.flutter.io/flutter/material/TextField/textInputAction.html)
  final TextInputAction? textInputAction;

  final bool enableInteractiveSelection;

  final Widget? leftButton, rightButton;
  final Widget? clearTextButton;

  /// Creates a QuickSearchTextFieldConfiguration
  const QuickSearchTextFieldConfiguration({
    this.decoration = const InputDecoration(),
    this.style,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.maxLengthEnforcement,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.textAlignVertical,
    this.autocorrect = true,
    this.inputFormatters,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.enableSuggestions = true,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.cursorColor,
    this.cursorRadius,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.cursorWidth = 2.0,
    this.keyboardAppearance,
    this.onEditingComplete,
    this.onTap,
    this.textDirection,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.leftButton,
    this.rightButton,
    this.clearTextButton,
  });

  /// Copies the [QuickSearchTextFieldConfiguration] and only changes the specified
  /// properties
  QuickSearchTextFieldConfiguration copyWith(
      {InputDecoration? decoration,
        TextStyle? style,
        TextEditingController? controller,
        ValueChanged<String>? onChanged,
        ValueChanged<String>? onSubmitted,
        bool? obscureText,
        MaxLengthEnforcement? maxLengthEnforcement,
        int? maxLength,
        int? maxLines,
        int? minLines,
        bool? autocorrect,
        List<TextInputFormatter>? inputFormatters,
        bool? autofocus,
        TextInputType? keyboardType,
        bool? enabled,
        bool? enableSuggestions,
        TextAlign? textAlign,
        FocusNode? focusNode,
        Color? cursorColor,
        TextAlignVertical? textAlignVertical,
        Radius? cursorRadius,
        double? cursorWidth,
        Brightness? keyboardAppearance,
        VoidCallback? onEditingComplete,
        GestureTapCallback? onTap,
        EdgeInsets? scrollPadding,
        TextCapitalization? textCapitalization,
        TextDirection? textDirection,
        TextInputAction? textInputAction,
        bool? enableInteractiveSelection,
        Widget? leftButton,
        Widget? rightButton,
        Widget? clearTextButton}) {
    return QuickSearchTextFieldConfiguration(
      decoration: decoration ?? this.decoration,
      style: style ?? this.style,
      controller: controller ?? this.controller,
      onChanged: onChanged ?? this.onChanged,
      onSubmitted: onSubmitted ?? this.onSubmitted,
      obscureText: obscureText ?? this.obscureText,
      maxLengthEnforcement: maxLengthEnforcement ?? this.maxLengthEnforcement,
      maxLength: maxLength ?? this.maxLength,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
      autocorrect: autocorrect ?? this.autocorrect,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      autofocus: autofocus ?? this.autofocus,
      keyboardType: keyboardType ?? this.keyboardType,
      enabled: enabled ?? this.enabled,
      enableSuggestions: enableSuggestions ?? this.enableSuggestions,
      textAlign: textAlign ?? this.textAlign,
      textAlignVertical: textAlignVertical ?? this.textAlignVertical,
      focusNode: focusNode ?? this.focusNode,
      cursorColor: cursorColor ?? this.cursorColor,
      cursorRadius: cursorRadius ?? this.cursorRadius,
      cursorWidth: cursorWidth ?? this.cursorWidth,
      keyboardAppearance: keyboardAppearance ?? this.keyboardAppearance,
      onEditingComplete: onEditingComplete ?? this.onEditingComplete,
      onTap: onTap ?? this.onTap,
      scrollPadding: scrollPadding ?? this.scrollPadding,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      textInputAction: textInputAction ?? this.textInputAction,
      textDirection: textDirection ?? this.textDirection,
      enableInteractiveSelection:
      enableInteractiveSelection ?? this.enableInteractiveSelection,
      leftButton: leftButton ?? this.leftButton,
      rightButton: rightButton ?? this.rightButton,
      clearTextButton: clearTextButton ?? this.clearTextButton,
    );
  }
}

class _SuggestionsBox {
  static const int waitMetricsTimeoutMillis = 1000;
  static const double minOverlaySpace = 64.0;

  final BuildContext context;
  final AxisDirection desiredDirection;
  final bool autoFlipDirection;
  final bool hideSuggestionBox;

  OverlayEntry? _overlayEntry;
  AxisDirection direction;

  bool isOpened = false;
  bool widgetMounted = true;
  double maxHeight = 300.0;
  double textBoxWidth = 100.0;
  double textBoxHeight = 100.0;
  late double directionUpOffset;

  _SuggestionsBox(
      this.context,
      this.direction,
      this.autoFlipDirection,
      this.hideSuggestionBox
      ) : desiredDirection = direction;

  void open() {
    if (hideSuggestionBox) return;
    if (isOpened) return;
    assert(_overlayEntry != null);
    resize();
    Overlay.of(context).insert(_overlayEntry!);
    isOpened = true;
  }

  void close() {
    if (!isOpened) return;
    assert(_overlayEntry != null);
    _overlayEntry!.remove();
    isOpened = false;
  }

  void toggle() {
    if (isOpened) {
      close();
    } else {
      open();
    }
  }

  MediaQuery? _findRootMediaQuery() {
    MediaQuery? rootMediaQuery;
    context.visitAncestorElements((element) {
      if (element.widget is MediaQuery) {
        rootMediaQuery = element.widget as MediaQuery;
      }
      return true;
    });

    return rootMediaQuery;
  }

  /// Delays until the keyboard has toggled or the orientation has fully changed
  Future<bool> _waitChangeMetrics() async {
    if (widgetMounted) {
      // initial viewInsets which are before the keyboard is toggled
      EdgeInsets initial = MediaQuery.of(context).viewInsets;
      // initial MediaQuery for orientation change
      MediaQuery? initialRootMediaQuery = _findRootMediaQuery();

      int timer = 0;
      // viewInsets or MediaQuery have changed once keyboard has toggled or orientation has changed
      while (widgetMounted && timer < waitMetricsTimeoutMillis) {
        // reduce delay if showDialog ever exposes detection of animation end
        await Future<void>.delayed(const Duration(milliseconds: 170));
        timer += 170;

        if (widgetMounted && context.mounted &&
            (MediaQuery.of(context).viewInsets != initial ||
                _findRootMediaQuery() != initialRootMediaQuery)) {
          return true;
        }
      }
    }

    return false;
  }

  void resize() {
    // check to see if widget is still mounted
    // user may have closed the widget with the keyboard still open
    if (widgetMounted) {
      _adjustMaxHeightAndOrientation();
      _overlayEntry!.markNeedsBuild();
    }
  }

  // See if there's enough room in the desired direction for the overlay to display
  // correctly. If not, try the opposite direction if things look more roomy there
  void _adjustMaxHeightAndOrientation() {
    TypeAheadFieldQuickSearch widget = context.widget as TypeAheadFieldQuickSearch;

    RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || box.hasSize == false) {
      return;
    }

    textBoxWidth = box.size.width;
    textBoxHeight = box.size.height;

    // top of text box
    double textBoxAbsY = box.localToGlobal(Offset.zero).dy;

    // height of window
    double windowHeight = MediaQuery.of(context).size.height;

    // we need to find the root MediaQuery for the unsafe area height
    // we cannot use BuildContext.ancestorWidgetOfExactType because
    // widgets like SafeArea creates a new MediaQuery with the padding removed
    MediaQuery rootMediaQuery = _findRootMediaQuery()!;

    // height of keyboard
    double keyboardHeight = rootMediaQuery.data.viewInsets.bottom;

    double maxHDesired = _calculateMaxHeight(desiredDirection, box, widget,
        windowHeight, rootMediaQuery, keyboardHeight, textBoxAbsY);

    // if there's enough room in the desired direction, update the direction and the max height
    if (maxHDesired >= minOverlaySpace || !autoFlipDirection) {
      direction = desiredDirection;
      maxHeight = maxHDesired;
    } else {
      // There's not enough room in the desired direction so see how much room is in the opposite direction
      AxisDirection flipped = flipAxisDirection(desiredDirection);
      double maxHFlipped = _calculateMaxHeight(flipped, box, widget,
          windowHeight, rootMediaQuery, keyboardHeight, textBoxAbsY);

      // if there's more room in this opposite direction, update the direction and maxHeight
      if (maxHFlipped > maxHDesired) {
        direction = flipped;
        maxHeight = maxHFlipped;
      }
    }

    if (maxHeight < 0) maxHeight = 0;
  }

  double _calculateMaxHeight(
      AxisDirection direction,
      RenderBox box,
      TypeAheadFieldQuickSearch widget,
      double windowHeight,
      MediaQuery rootMediaQuery,
      double keyboardHeight,
      double textBoxAbsY) {
    return direction == AxisDirection.down
        ? _calculateMaxHeightDown(box, widget, windowHeight, rootMediaQuery,
        keyboardHeight, textBoxAbsY)
        : _calculateMaxHeightUp(box, widget, windowHeight, rootMediaQuery,
        keyboardHeight, textBoxAbsY);
  }

  double _calculateMaxHeightDown(
      RenderBox box,
      TypeAheadFieldQuickSearch widget,
      double windowHeight,
      MediaQuery rootMediaQuery,
      double keyboardHeight,
      double textBoxAbsY) {
    // unsafe area, ie: iPhone X 'home button'
    // keyboardHeight includes unsafeAreaHeight, if keyboard is showing, set to 0
    double unsafeAreaHeight =
    keyboardHeight == 0 ? rootMediaQuery.data.padding.bottom : 0;

    return windowHeight -
        keyboardHeight -
        unsafeAreaHeight -
        textBoxHeight -
        textBoxAbsY -
        2 * widget.suggestionsBoxVerticalOffset;
  }

  double _calculateMaxHeightUp(
      RenderBox box,
      TypeAheadFieldQuickSearch widget,
      double windowHeight,
      MediaQuery rootMediaQuery,
      double keyboardHeight,
      double textBoxAbsY) {
    // recalculate keyboard absolute y value
    double keyboardAbsY = windowHeight - keyboardHeight;

    directionUpOffset = textBoxAbsY > keyboardAbsY
        ? keyboardAbsY - textBoxAbsY - widget.suggestionsBoxVerticalOffset
        : -widget.suggestionsBoxVerticalOffset;

    // unsafe area, ie: iPhone X notch
    double unsafeAreaHeight = rootMediaQuery.data.padding.top;

    return textBoxAbsY > keyboardAbsY
        ? keyboardAbsY -
        unsafeAreaHeight -
        2 * widget.suggestionsBoxVerticalOffset
        : textBoxAbsY -
        unsafeAreaHeight -
        2 * widget.suggestionsBoxVerticalOffset;
  }

  Future<void> onChangeMetrics() async {
    if (await _waitChangeMetrics()) {
      resize();
    }
  }
}

/// Supply an instance of this class to the [TypeAhead.suggestionsBoxController]
/// property to manually control the suggestions box
class QuickSearchSuggestionsBoxController {
  _SuggestionsBox? _suggestionsBox;
  FocusNode? _effectiveFocusNode;

  /// Opens the suggestions box
  void open() {
    _effectiveFocusNode!.requestFocus();
  }

  bool isOpened() {
    return _suggestionsBox!.isOpened;
  }

  /// Closes the suggestions box
  void close() {
    _effectiveFocusNode!.unfocus();
  }

  /// Opens the suggestions box if closed and vice-versa
  void toggle() {
    if (_suggestionsBox!.isOpened) {
      close();
    } else {
      open();
    }
  }

  /// Recalculates the height of the suggestions box
  void resize() {
    _suggestionsBox!.resize();
  }
}