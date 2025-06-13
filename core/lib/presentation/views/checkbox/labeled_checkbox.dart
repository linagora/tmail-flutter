import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

typedef OnChangedAction = void Function(bool? value);

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    Key? key,
    required this.label,
    required this.onChanged,
    this.value = false,
    this.gap = 4.0,
    this.textStyle,
  }) : super(key: key);

  final String label;
  final bool value;
  final OnChangedAction onChanged;
  final double gap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!(value)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          buildCheckboxWidget,
          buildGapWidget,
          buildLabelWidget,
        ],
      ),
    );
  }

  Widget get buildCheckboxWidget => Checkbox(
        value: value,
        visualDensity: VisualDensity.compact,
        onChanged: onChanged,
      );

  Widget get buildGapWidget => SizedBox(width: gap);

  Widget get buildLabelWidget => Text(
        label,
        style: textStyle ?? ThemeUtils.textStyleM3BodyMedium3,
      );
}
