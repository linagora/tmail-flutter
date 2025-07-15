import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/semantics/text_field_semantics.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';

class TextFieldBuilder extends StatefulWidget {

  final ValueChanged<String>? onTextChange;
  final ValueChanged<String>? onTextSubmitted;
  final VoidCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final TextStyle? textStyle;
  final TextInputAction? textInputAction;
  final InputDecoration decoration;
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
  final String? semanticLabel;

  const TextFieldBuilder({
    super.key,
    this.cursorColor = AppColor.primaryColor,
    this.autocorrect = false,
    this.obscureText = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.textStyle,
    this.textDirection = TextDirection.ltr,
    this.textInputAction,
    this.decoration = const InputDecoration(),
    this.maxLines,
    this.minLines,
    this.controller,
    this.keyboardType,
    this.focusNode,
    this.fromValue,
    this.keyboardAppearance,
    this.mouseCursor,
    this.semanticLabel,
    this.onTap,
    this.onTapOutside,
    this.onTextChange,
    this.onTextSubmitted,
  });

  @override
  State<TextFieldBuilder> createState() => _TextFieldBuilderState();
}

class _TextFieldBuilderState extends State<TextFieldBuilder> {

  TextEditingController? _controller;

  late TextDirection _textDirection;

  @override
  void initState() {
    super.initState();
    if (widget.fromValue != null) {
      _controller = TextEditingController.fromValue(
        TextEditingValue(text: widget.fromValue!),
      );
    } else {
      _controller = widget.controller ?? TextEditingController();
    }
    _textDirection = widget.textDirection;
  }

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      key: widget.key,
      controller: _controller,
      cursorColor: widget.cursorColor,
      autocorrect: widget.autocorrect,
      textInputAction: widget.textInputAction,
      decoration: widget.decoration,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      keyboardAppearance: widget.keyboardAppearance,
      style: widget.textStyle ?? ThemeUtils.defaultTextStyleInterFont.copyWith(
        color: AppColor.textFieldTextColor,
      ),
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      autofocus: widget.autoFocus,
      focusNode: widget.focusNode,
      textDirection: _textDirection,
      readOnly: widget.readOnly,
      mouseCursor: widget.mouseCursor,
      onChanged: _onTextChanged,
      onSubmitted: widget.onTextSubmitted,
      onTap: widget.onTap,
      onTapOutside: widget.onTapOutside,
    );

    if (widget.semanticLabel != null) {
      return TextFieldSemantics(
        label: widget.semanticLabel!,
        value: _controller?.text ?? '',
        child: textField,
      );
    } else {
      return textField;
    }
  }

  void _onTextChanged(String value) {
    widget.onTextChange?.call(value);

    if (value.trim().isEmpty) return;

    final directionByText = DirectionUtils.getDirectionByEndsText(value);
    if (directionByText != _textDirection) {
      setState(() {
        _textDirection = directionByText;
      });
    }
  }
  @override
  void dispose() {
    if (widget.controller == null) {
      _controller?.dispose();
    }
    super.dispose();
  }
}