import 'package:flutter/material.dart';

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    required this.label,
    this.contentPadding,
    this.value,
    this.onChanged,
    this.activeColor,
    this.fontSize = 16,
    this.gap = 4.0,
    this.bold = false,
    this.focusNode,
  });

  final String label;
  final EdgeInsets? contentPadding;
  final bool? value;
  final Function(bool?)? onChanged;
  final Color? activeColor;
  final double fontSize;
  final double gap;
  final bool bold;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged?.call(!(value ?? false)),
      child: Padding(
        padding: contentPadding ?? const EdgeInsets.all(0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Checkbox(
              value: value,
              activeColor: activeColor,
              visualDensity: VisualDensity.compact,
              focusNode: focusNode,
              onChanged: onChanged,
            ),
            SizedBox(
              width: gap,
            ),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}