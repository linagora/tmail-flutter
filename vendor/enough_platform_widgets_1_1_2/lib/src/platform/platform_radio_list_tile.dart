import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

/// Provides a RadioListTile implementation for both material and cupertino
class PlatformRadioListTile<T> extends StatelessWidget {
  final Key? widgetKey;
  final T? groupValue;
  final T value;
  final void Function(T? value)? onChanged;
  final bool toggable;
  final Widget? title;
  final Widget? subtitle;
  final EdgeInsetsGeometry? contentPadding;
  final Color? activeColor;

  const PlatformRadioListTile({
    Key? key,
    this.widgetKey,
    required this.groupValue,
    required this.value,
    required this.onChanged,
    this.toggable = false,
    this.title,
    this.subtitle,
    this.activeColor,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => RadioListTile<T>(
        key: widgetKey,
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        toggleable: toggable,
        title: title,
        subtitle: subtitle,
        activeColor: activeColor,
        contentPadding: contentPadding,
      ),
      cupertino: (context, platform) => CupertinoRadioListTile<T>(
        key: widgetKey,
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        toggable: toggable,
        title: title,
        subtitle: subtitle,
        activeColor: activeColor,
        contentPadding: contentPadding,
      ),
    );
  }
}
