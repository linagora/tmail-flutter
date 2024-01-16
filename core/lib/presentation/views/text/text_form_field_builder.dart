import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';

typedef OnValidator = String? Function(String? value);

class TextFormFieldBuilder extends StatefulWidget {

  final ValueChanged<String>? onTextChange;
  final ValueChanged<String>? onTextSubmitted;
  final VoidCallback? onTap;
  final TextStyle? textStyle;
  final TextInputAction? textInputAction;
  final InputDecoration? decoration;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Color cursorColor;
  final bool autoFocus;
  final FocusNode? focusNode;
  final String? fromValue;
  final Brightness? keyboardAppearance;
  final bool autocorrect;
  final TextDirection textDirection;
  final bool readOnly;
  final MouseCursor? mouseCursor;
  final List<String>? autofillHints;
  final OnValidator? validator;

  const TextFormFieldBuilder({
    super.key,
    this.cursorColor = AppColor.primaryColor,
    this.autocorrect = false,
    this.obscureText = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.textStyle = const TextStyle(color: AppColor.textFieldTextColor),
    this.textDirection = TextDirection.ltr,
    this.textInputAction,
    this.decoration,
    this.maxLines = 1,
    this.minLines,
    this.controller,
    this.keyboardType,
    this.focusNode,
    this.fromValue,
    this.keyboardAppearance,
    this.mouseCursor,
    this.autofillHints,
    this.onTap,
    this.onTextChange,
    this.onTextSubmitted,
    this.validator,
  });

  @override
  State<TextFormFieldBuilder> createState() => _TextFieldFormBuilderState();
}

class _TextFieldFormBuilderState extends State<TextFormFieldBuilder> {

  late TextEditingController _controller;
  late TextDirection _textDirection;

  @override
  void initState() {
    if (widget.fromValue != null) {
      _controller = TextEditingController.fromValue(TextEditingValue(text: widget.fromValue!));
    } else if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
    }
    _textDirection = widget.textDirection;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.key,
      controller: _controller,
      cursorColor: widget.cursorColor,
      autocorrect: widget.autocorrect,
      textInputAction: widget.textInputAction,
      decoration: widget.decoration,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      keyboardAppearance: widget.keyboardAppearance,
      style: widget.textStyle,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      autofocus: widget.autoFocus,
      focusNode: widget.focusNode,
      textDirection: _textDirection,
      readOnly: widget.readOnly,
      mouseCursor: widget.mouseCursor,
      autofillHints: widget.autofillHints,
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
      onTap: widget.onTap,
      validator: widget.validator,
    );
  }

  @override
  void dispose() {
    if (widget.fromValue == null && widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
}