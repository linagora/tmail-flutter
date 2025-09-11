import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';

typedef OnSelectValueAction<T> = Function(T? value);

class LabelBorderButtonField<T> extends StatelessWidget {
  final T? value;
  final bool isEmpty;
  final bool arrangeHorizontally;
  final String label;
  final String? hintText;
  final double? horizontalSpacing;
  final double? minWidth;
  final OnSelectValueAction onSelectValueAction;

  const LabelBorderButtonField({
    super.key,
    required this.value,
    required this.label,
    required this.onSelectValueAction,
    this.isEmpty = false,
    this.arrangeHorizontally = true,
    this.hintText,
    this.minWidth,
    this.horizontalSpacing,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonField = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => onSelectValueAction(value),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Container(
          height: 40,
          constraints: BoxConstraints(minWidth: minWidth ?? 106),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: _getBorderColor(), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          child: Text(
            _getName(context, value),
            style: _getTextStyle(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );

    if (arrangeHorizontally) {
      buttonField = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 83),
            child: Text(
              '$label:',
              style: ThemeUtils.textStyleBodyBody3(color: Colors.black),
            ),
          ),
          SizedBox(width: horizontalSpacing ?? 12),
          buttonField,
        ],
      );
    } else {
      buttonField = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: ThemeUtils.textStyleBodyBody3(color: Colors.black),
          ),
          const SizedBox(height: 10),
          buttonField,
        ],
      );
    }

    return buttonField;
  }

  TextStyle? _getTextStyle(T? value) {
    if (hintText != null && value == null) {
      return ThemeUtils.textStyleBodyBody3(color: AppColor.steelGray400);
    } else {
      return ThemeUtils.textStyleBodyBody3(color: Colors.black);
    }
  }

  String _getName(BuildContext context, T? value) {
    if (value is DateTime) {
      return value.formatDate(
        pattern: 'dd/MM/yyyy',
        locale: Localizations.localeOf(context).toLanguageTag(),
      );
    }
    if (value is TimeOfDay) {
      return value.formatTime(context);
    }
    return hintText ?? '';
  }

  Color _getBorderColor() =>
      isEmpty ? AppColor.redFF3347 : AppColor.m3Neutral90;
}
