import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:flutter/material.dart';

typedef OnTextSubmitted = void Function(String text);
typedef OnTextChange = void Function(String text);

class DefaultInputFieldWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final String? hintText;
  final String? errorText;
  final Color? inputColor;
  final bool hasMaxLines;
  final bool isFillContainer;
  final TextAlignVertical? textAlignVertical;
  final double? maxHeight;
  final FocusNode? focusNode;
  final TextInputAction? inputAction;
  final OnTextChange? onTextChange;
  final OnTextSubmitted? onTextSubmitted;
  final int? errorMaxLines;

  const DefaultInputFieldWidget({
    super.key,
    required this.textEditingController,
    this.hintText,
    this.errorText,
    this.focusNode,
    this.inputColor,
    this.hasMaxLines = true,
    this.isFillContainer = false,
    this.textAlignVertical,
    this.maxHeight,
    this.inputAction,
    this.onTextChange,
    this.onTextSubmitted,
    this.errorMaxLines,
  });

  bool get _wrapsErrorText => errorMaxLines != null && errorText?.isNotEmpty == true;

  EdgeInsetsGeometry get _contentPadding {
    if (_wrapsErrorText) {
      // Dense padding gives the input the same 40px it gets under the 60px cap,
      // while letting the error text grow below it.
      return const EdgeInsetsDirectional.only(start: 12, end: 8, top: 10, bottom: 10);
    }
    return errorText?.isNotEmpty == true
      ? const EdgeInsetsDirectional.only(start: 12, end: 8)
      : const EdgeInsetsDirectional.only(start: 12, end: 8, top: 12, bottom: 12);
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldBuilder(
      controller: textEditingController,
      maxLines: hasMaxLines ? 1 : null,
      textInputAction: inputAction ?? TextInputAction.next,
      textStyle: ThemeUtils.textStyleBodyBody3(
        color: inputColor ?? AppColor.m3SurfaceBackground,
      ),
      isFillContainer: isFillContainer,
      textAlignVertical: textAlignVertical,
      focusNode: focusNode,
      onTextSubmitted: onTextSubmitted,
      onTextChange: onTextChange,
      decoration: InputDecoration(
        constraints: _wrapsErrorText
          ? null
          : BoxConstraints(
              maxHeight: maxHeight ?? (errorText?.isNotEmpty == true ? 60 : 40),
            ),
        isDense: _wrapsErrorText,
        filled: true,
        fillColor: errorText?.isNotEmpty == true
            ? AppColor.colorInputBackgroundErrorVerifyName
            : Colors.white,
        contentPadding: _contentPadding,
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(width: 1, color: AppColor.m3Neutral90),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(width: 1, color: AppColor.m3Neutral90),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(width: 1, color: AppColor.primaryColor),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(width: 1, color: AppColor.redFF3347),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(width: 1, color: AppColor.redFF3347),
        ),
        hintText: hintText,
        hintStyle: ThemeUtils.textStyleBodyBody3(color: AppColor.m3Tertiary),
        errorText: errorText,
        errorMaxLines: errorMaxLines,
        errorStyle: ThemeUtils.textStyleBodyBody3(color: AppColor.redFF3347),
      ),
    );
  }
}
