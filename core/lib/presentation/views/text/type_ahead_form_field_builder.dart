import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/quick_search/quick_search_input_form.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class TypeAheadFormFieldBuilder<T> extends StatefulWidget {

  final TextDirection textDirection;
  final Duration debounceDuration;
  final SuggestionsCallback<T> suggestionsCallback;
  final ItemBuilder<T> itemBuilder;
  final SuggestionSelectionCallback<T> onSuggestionSelected;
  final BoxDecoration suggestionsBoxDecoration;
  final WidgetBuilder? noItemsFoundBuilder;
  final bool hideOnEmpty;
  final bool hideOnError;
  final bool hideOnLoading;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onTextChange;
  final ValueChanged<String>? onTextSubmitted;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final List<String>? autofillHints;
  final TextInputType keyboardType;
  final InputDecoration decoration;
  final Color cursorColor;

  const TypeAheadFormFieldBuilder({
    super.key,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.onSuggestionSelected,
    this.suggestionsBoxDecoration = const BoxDecoration(),
    this.textDirection = TextDirection.ltr,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.decoration = const InputDecoration(),
    this.noItemsFoundBuilder,
    this.hideOnEmpty = false,
    this.hideOnError = false,
    this.hideOnLoading = false,
    this.autocorrect = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.focusNode,
    this.cursorColor = AppColor.primaryColor,
    this.autofillHints,
    this.textInputAction,
    this.onTextChange,
    this.onTextSubmitted,
  });

  @override
  State<TypeAheadFormFieldBuilder<T>> createState() => _TypeAheadFormFieldBuilderState<T>();
}

class _TypeAheadFormFieldBuilderState<T> extends State<TypeAheadFormFieldBuilder<T>> {

  late TextEditingController _controller;
  late TextDirection _textDirection;

  @override
  void initState() {
    super.initState();
    _textDirection = widget.textDirection;
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<T>(
      controller: widget.controller,
      focusNode: widget.focusNode,
      debounceDuration: widget.debounceDuration,
      itemBuilder: widget.itemBuilder,
      onSelected: widget.onSuggestionSelected,
      suggestionsCallback: widget.suggestionsCallback,
      decorationBuilder: (context, child) => Material(
        elevation: 4.0,
        shadowColor: Colors.black,
        borderRadius: widget.suggestionsBoxDecoration.borderRadius,
        child: child),
      emptyBuilder: widget.noItemsFoundBuilder,
      hideOnEmpty: widget.hideOnEmpty,
      hideOnError: widget.hideOnError,
      hideOnLoading: widget.hideOnLoading,
      builder: (context, controller, focusNode) {
        return TextFormField(
          key: widget.key,
          controller: controller,
          focusNode: focusNode,
          textInputAction: widget.textInputAction,
          autocorrect: widget.autocorrect,
          autofillHints: widget.autofillHints,
          keyboardType: widget.keyboardType,
          decoration: widget.decoration,
          textDirection: _textDirection,
          cursorColor: widget.cursorColor,
          onChanged: (value) {
          widget.onTextChange?.call(value);
            if (value.isNotEmpty) {
              final directionByText = DirectionUtils.getDirectionByEndsText(value);
              if (directionByText != _textDirection) {
                setState(() {
                  _textDirection = directionByText;
                });
              }
            }
          },
          onFieldSubmitted: widget.onTextSubmitted,
        );
      },
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
}