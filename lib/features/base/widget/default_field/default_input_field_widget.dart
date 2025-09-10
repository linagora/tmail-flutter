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
  final FocusNode? focusNode;
  final OnTextChange? onTextChange;
  final OnTextSubmitted? onTextSubmitted;

  const DefaultInputFieldWidget({
    super.key,
    required this.textEditingController,
    this.hintText,
    this.errorText,
    this.focusNode,
    this.inputColor,
    this.onTextChange,
    this.onTextSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldBuilder(
      controller: textEditingController,
      maxLines: 1,
      textInputAction: TextInputAction.next,
      textStyle: ThemeUtils.textStyleBodyBody3(
        color: inputColor ?? AppColor.m3SurfaceBackground,
      ),
      focusNode: focusNode,
      onTextSubmitted: onTextSubmitted,
      onTextChange: onTextChange,
      decoration: InputDecoration(
        constraints: BoxConstraints(
          maxHeight: errorText?.isNotEmpty == true ? 60 : 40,
        ),
        filled: true,
        fillColor: errorText?.isNotEmpty == true
            ? AppColor.colorInputBackgroundErrorVerifyName
            : Colors.white,
        contentPadding: errorText?.isNotEmpty == true
          ? const EdgeInsetsDirectional.only(start: 12, end: 8)
          : const EdgeInsetsDirectional.only(start: 12, end: 8, top: 12, bottom: 12),
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
        errorStyle: ThemeUtils.textStyleBodyBody3(color: AppColor.redFF3347),
      ),
    );
  }
}
