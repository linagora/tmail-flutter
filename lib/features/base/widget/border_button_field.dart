
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';

typedef OnTapActionCallback<T> = Function(T? value);

class BorderButtonField<T> extends StatelessWidget {

  final T? value;
  final OnTapActionCallback? tapActionCallback;
  final Widget? icon;
  final TextStyle? textStyle;
  final MouseCursor? mouseCursor;
  final String? hintText;
  final bool isEmpty;
  final Color? backgroundColor;
  final String? label;

  const BorderButtonField({
    super.key,
    this.label,
    this.value,
    this.tapActionCallback,
    this.icon,
    this.textStyle,
    this.mouseCursor,
    this.hintText,
    this.isEmpty = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonField = InkWell(
      onTap: () => tapActionCallback?.call(value),
      mouseCursor: mouseCursor,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: _getBorderColor(),
                width: 0.5),
            color: backgroundColor ?? Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          Expanded(child: Text(
            _getName(context, value),
            style: _getTextStyle(value),
            maxLines: 1,
            softWrap: CommonTextStyle.defaultSoftWrap,
            overflow: CommonTextStyle.defaultTextOverFlow,
          )),
          if (icon != null) icon!
        ]),
      ),
    );
    if (label != null) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label!, style: ThemeUtils.defaultTextStyleInterFont.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColor.colorContentEmail)),
        const SizedBox(height: 8),
        buttonField
      ]);
    } else {
      return buttonField;
    }
  }

  TextStyle? _getTextStyle(T? value) {
    if (hintText != null && value == null) {
      return ThemeUtils.defaultTextStyleInterFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColor.colorHintInputCreateMailbox);
    }
    return textStyle ?? ThemeUtils.defaultTextStyleInterFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.black);
  }

  String _getName(BuildContext context, T? value) {
    if (value is DateTime) {
      return value.formatDate(locale: Localizations.localeOf(context).toLanguageTag());
    }
    if (value is TimeOfDay) {
      return value.formatTime(context);
    }
    return hintText ?? '';
  }

  Color _getBorderColor() {
    if (!isEmpty) {
      return AppColor.colorInputBorderCreateMailbox;
    }
    return AppColor.colorInputBorderErrorVerifyName;
  }
}