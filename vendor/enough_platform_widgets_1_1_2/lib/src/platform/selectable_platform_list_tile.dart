import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// Uses either a `ListTile` or a `CupertinoListTile`
class SelectablePlatformListTile extends StatelessWidget {
  const SelectablePlatformListTile({
    Key? key,
    this.widgetKey,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.isThreeLine = false,
    this.onTap,
    this.onLongPress,
    this.visualDensity,
    this.selected = false,
    this.mouseCursor,
    this.dense,
    this.shape,
    this.contentPadding,
    this.enabled = true,
    this.focusColor,
    this.hoverColor,
    this.focusNode,
    this.autofocus = false,
    this.tileColor,
    this.selectedTileColor,
    this.enableFeedback,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.minLeadingWidth,
  }) : super(key: key);

  final Key? widgetKey;
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final bool isThreeLine;
  final void Function()? onTap;

  /// Callback for long press gesture - only usable on Material
  final void Function()? onLongPress;

  /// Material-only mouse cursor
  final MouseCursor? mouseCursor;
  final bool selected;
  final bool? dense;
  final VisualDensity? visualDensity;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? tileColor;
  final Color? selectedTileColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool? enableFeedback;
  final double? horizontalTitleGap;
  final double? minVerticalPadding;
  final double? minLeadingWidth;

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => ListTile(
        key: widgetKey,
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        isThreeLine: isThreeLine,
        dense: dense,
        visualDensity: visualDensity,
        shape: shape,
        contentPadding: contentPadding,
        enabled: enabled,
        onTap: onTap,
        onLongPress: onLongPress,
        mouseCursor: mouseCursor,
        selected: selected,
        focusColor: focusColor,
        hoverColor: hoverColor,
        focusNode: focusNode,
        autofocus: autofocus,
        tileColor: tileColor,
        selectedTileColor: selectedTileColor,
        enableFeedback: enableFeedback,
        horizontalTitleGap: horizontalTitleGap,
        minVerticalPadding: minVerticalPadding,
        minLeadingWidth: minLeadingWidth,
      ),
      cupertino: (context, platform) => CupertinoListTile(
        key: widgetKey,
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        leadingSize: (dense ?? false) ? 14 : 28,
        onTap: onTap,
      ),
    );
  }
}
