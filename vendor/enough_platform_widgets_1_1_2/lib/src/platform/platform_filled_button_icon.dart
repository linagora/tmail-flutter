import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Uses an ElevatedButton.filled on material and a CupertinoButton.filled on cupertino
class PlatformFilledButtonIcon extends StatelessWidget {
  final Key? widgetKey;
  final void Function() onPressed;
  final void Function()? onLongPress;
  final Widget icon;
  final Widget label;
  final bool? autofocus;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final Clip? clipBehavior;

  /// only applicable for cupertino
  final Color? backgroundColor;

  /// Important: onLongPress, autofocus, focusNode and clip behavior are not supported for cupertino
  const PlatformFilledButtonIcon({
    Key? key,
    this.widgetKey,
    required this.onPressed,
    required this.icon,
    this.onLongPress,
    required this.label,
    this.autofocus,
    this.style,
    this.focusNode,
    this.clipBehavior,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => ElevatedButton.icon(
        key: widgetKey,
        onPressed: onPressed,
        onLongPress: onLongPress,
        label: label,
        icon: icon,
        style: style,
        focusNode: focusNode,
        clipBehavior: clipBehavior,
        autofocus: autofocus ?? false,
      ),
      cupertino: (context, platform) => CupertinoButton.filled(
        padding: EdgeInsets.all(8.0),
        key: widgetKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: icon,
            ),
            Expanded(child: label),
          ],
        ),
        onPressed: onPressed,
      ),
    );
  }
}
