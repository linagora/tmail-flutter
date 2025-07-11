import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/checkbox/labeled_checkbox.dart';
import 'package:core/presentation/views/semantics/checkbox_semantics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIconLabeledCheckbox extends LabeledCheckbox {

  final String svgIconPath;
  final String selectedSvgIconPath;
  final FocusNode? focusNode;
  final String? semanticsLabel;

  const CustomIconLabeledCheckbox({
    super.key,
    required super.label,
    required super.onChanged,
    required this.svgIconPath,
    required this.selectedSvgIconPath,
    this.focusNode,
    this.semanticsLabel,
    super.value,
    super.gap = 16.0,
    super.padding,
  });

  @override
  Widget get buildCheckboxWidget {
    Widget bodyWidget;

    if (focusNode != null) {
      bodyWidget = FocusableActionDetector(
        focusNode: focusNode,
        autofocus: false,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            canRequestFocus: true,
            focusColor: AppColor.colorMailboxHovered,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            onTap: () => onChanged(!(value)),
            child: SvgPicture.asset(
              value ? selectedSvgIconPath : svgIconPath,
              width: 20,
              height: 20,
              colorFilter: AppColor.primaryColor.asFilter(),
              fit: BoxFit.fill,
            ),
          ),
        ),
      );
    } else {
      bodyWidget = Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          onTap: () => onChanged(!(value)),
          child: SvgPicture.asset(
            value ? selectedSvgIconPath : svgIconPath,
            width: 20,
            height: 20,
            colorFilter: AppColor.primaryColor.asFilter(),
            fit: BoxFit.fill,
          ),
        ),
      );
    }

    if (semanticsLabel != null) {
      return CheckboxSemantics(
        label: semanticsLabel!,
        value: value,
        child: bodyWidget,
      );
    } else {
      return bodyWidget;
    }
  }
}
