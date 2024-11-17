import 'package:core/presentation/views/quick_search/quick_search_action_define.dart';
import 'package:core/presentation/views/quick_search/quick_search_suggestion_box_controller.dart';
import 'package:core/presentation/views/quick_search/quick_search_suggestion_box_decoration.dart';
import 'package:core/presentation/views/quick_search/quick_search_text_field_configuration.dart';
import 'package:core/presentation/views/quick_search/type_ahead_field_quick_search.dart';
import 'package:flutter/material.dart';

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
  QuickSearchInputForm({
    Key? key,
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
    bool keepSuggestionsOnLoading = false,
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
    int? minInputLengthAutocomplete,
    ItemBuilder<P>? contactItemBuilder,
    SuggestionsCallback<P>? contactSuggestionsCallback,
    SuggestionSelectionCallback<P>? onContactSuggestionSelected,
  })  : assert(
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
            final _QuickSearchInputFormFormFieldState state = field
                as _QuickSearchInputFormFormFieldState<dynamic, dynamic,
                    dynamic>;

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
              minInputLengthAutocomplete: minInputLengthAutocomplete,
              contactItemBuilder: contactItemBuilder,
              contactSuggestionsCallback: contactSuggestionsCallback,
              onContactSuggestionSelected: onContactSuggestionSelected,
            );
          },
        );

  @override
  FormFieldState<String> createState() =>
      _QuickSearchInputFormFormFieldState<T, P, R>();
}

class _QuickSearchInputFormFormFieldState<T, P, R>
    extends FormFieldState<String> {
  TextEditingController? _controller;

  TextEditingController? get _effectiveController =>
      widget.textFieldConfiguration.controller ?? _controller;

  @override
  QuickSearchInputForm get widget =>
      super.widget as QuickSearchInputForm<dynamic, dynamic, dynamic>;

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
