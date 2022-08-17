
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';

typedef OnTapActionCallback<T> = Function(T? value);

class BorderButtonField<T> extends StatelessWidget {

  final T? value;
  final OnTapActionCallback? tapActionCallback;
  final Widget? icon;
  final TextStyle? textStyle;
  final MouseCursor? mouseCursor;
  final String? hintText;

  const BorderButtonField({
    super.key,
    this.value,
    this.tapActionCallback,
    this.icon,
    this.textStyle,
    this.mouseCursor,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final _imagePaths = Get.find<ImagePaths>();

    return InkWell(
      onTap: () => tapActionCallback?.call(value),
      mouseCursor: mouseCursor,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AppColor.colorInputBorderCreateMailbox,
                width: 1),
            color: Colors.white),
        padding: const EdgeInsets.only(left: 12, right: 10),
        child: Row(children: [
          Expanded(child: Text(
            _getName(context, value),
            style: _getTextStyle(value),
            maxLines: 1,
            softWrap: CommonTextStyle.defaultSoftWrap,
            overflow: CommonTextStyle.defaultTextOverFlow,
          )),
          icon ?? SvgPicture.asset(_imagePaths.icDropDown)
        ]),
      ),
    );
  }

  TextStyle? _getTextStyle(T? value) {
    if (hintText != null && value == null) {
      return const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColor.colorHintInputCreateMailbox);
    }
    return textStyle ?? const TextStyle(
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
}