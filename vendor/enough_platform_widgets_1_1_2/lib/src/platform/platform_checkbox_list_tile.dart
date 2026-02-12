import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

/// A platform aware simple checkbox list tile
class PlatformCheckboxListTile extends StatelessWidget {
  final bool? value;
  final void Function(bool? value)? onChanged;
  final Widget? title;
  final Widget? subtitle;
  final EdgeInsetsGeometry? contentPadding;
  final Color? activeColor;
  final Color? checkColor;
  final bool selected;

  /// Creates a new checkbox list tile with the given [value] and [onChanged] callback.
  const PlatformCheckboxListTile({
    Key? key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.contentPadding,
    this.activeColor,
    this.checkColor,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => CheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: title,
        subtitle: subtitle,
        contentPadding: contentPadding,
        activeColor: activeColor,
        checkColor: checkColor,
        selected: selected,
      ),
      cupertino: (context, platform) => CupertinoCheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: title,
        subtitle: subtitle,
        contentPadding: contentPadding,
        activeColor: activeColor,
        checkColor: checkColor,
      ),
    );
  }
}
