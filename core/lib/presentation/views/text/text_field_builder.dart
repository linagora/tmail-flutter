import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/text/text_drop_zone_web.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:languagetool_textfield/languagetool_textfield.dart';

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
  final LanguageToolController? languageToolController;
  final bool dropTextEnabled;

  const TextFieldBuilder({
    super.key,
    this.cursorColor = AppColor.primaryColor,
    this.autocorrect = false,
    this.obscureText = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.textStyle = const TextStyle(color: AppColor.textFieldTextColor),
    this.textDirection = TextDirection.ltr,
    this.textInputAction,
    this.decoration = const InputDecoration(),
    this.maxLines,
    this.minLines,
    this.controller,
    this.languageToolController,
    this.keyboardType,
    this.focusNode,
    this.fromValue,
    this.keyboardAppearance,
    this.mouseCursor,
    this.onTap,
    this.onTapOutside,
    this.onTextChange,
    this.onTextSubmitted,
    this.dropTextEnabled = false,
  });

  @override
  State<TextFieldBuilder> createState() => _TextFieldBuilderState();
}

class _TextFieldBuilderState extends State<TextFieldBuilder> {

  TextEditingController? _controller;
  LanguageToolController? _languageToolController;

  late TextDirection _textDirection;

  @override
  void initState() {
    super.initState();
    if (widget.languageToolController != null) {
      _languageToolController = widget.languageToolController;
      if (widget.fromValue != null) {
        _languageToolController?.value = TextEditingValue(text: widget.fromValue!);
      }
    } else {
      if (widget.fromValue != null) {
        _controller = TextEditingController.fromValue(TextEditingValue(text: widget.fromValue!));
      } else {
        _controller = widget.controller ?? TextEditingController();
      }
    }
    _textDirection = widget.textDirection;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_languageToolController != null) {
      child = LanguageToolTextField(
        key: widget.key,
        controller: _languageToolController!,
        cursorColor: widget.cursorColor,
        autocorrect: widget.autocorrect,
        textInputAction: widget.textInputAction,
        decoration: widget.decoration,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        keyboardAppearance: widget.keyboardAppearance,
        style: widget.textStyle,
        keyboardType: widget.keyboardType,
        autoFocus: widget.autoFocus,
        focusNode: widget.focusNode,
        alignCenter: false,
        textDirection: _textDirection,
        readOnly: widget.readOnly,
        mouseCursor: widget.mouseCursor,
        onTextChange: _onChanged,
        onTextSubmitted: widget.onTextSubmitted,
        onTap: widget.onTap,
        onTapOutside: widget.onTapOutside,
      );
    } else {
      child = TextField(
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
        onChanged: _onChanged,
        onSubmitted: widget.onTextSubmitted,
        onTap: widget.onTap,
        onTapOutside: widget.onTapOutside,
      );
    }

    if (!widget.dropTextEnabled) return child;

    return TextDropZoneWeb(
      onDrop: (value) {
        (_languageToolController ?? _controller)?.text += value;
        widget.focusNode?.requestFocus();
        _onChanged(value);
      },
      child: child,
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller?.dispose();
    }
    if (widget.languageToolController == null) {
      _languageToolController?.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value) {
    widget.onTextChange?.call(value);
    if (value.isNotEmpty) {
      final directionByText = DirectionUtils.getDirectionByEndsText(value);
      if (directionByText != _textDirection) {
        setState(() {
          _textDirection = directionByText;
        });
      }
    }
  }
}