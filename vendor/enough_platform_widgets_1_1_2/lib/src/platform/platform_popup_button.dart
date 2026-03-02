import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// Provides a platform aware replacement for the material PopupMenuButton
class PlatformPopupMenuButton<T> extends StatelessWidget {
  final Widget? child;
  final void Function(T value)? onSelected;
  final List<PlatformPopupMenuEntry<T>> Function(BuildContext context)
      itemBuilder;
  final Widget? title;
  final Widget? message;
  final Widget? icon;
  final EdgeInsets? cupertinoButtonPadding;

  PlatformPopupMenuButton({
    Key? key,
    this.child,
    required this.itemBuilder,
    this.onSelected,
    this.title,
    this.message,
    this.icon,
    this.cupertinoButtonPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = title;
    final m = message;
    return PlatformWidget(
      material: (context, platform) {
        final popupItems = itemBuilder(context)
            .map((e) => _toMaterialEntry(e, context))
            .toList();
        if (t != null || m != null) {
          final header = PopupMenuItem<T>(
            //value: null,
            child: Column(
              children: [
                if (t != null) ...{
                  t,
                },
                if (m != null) ...{
                  m,
                }
              ],
            ),
          );
          popupItems.insert(0, header);
        }
        return PopupMenuButton<T>(
          icon: icon,
          itemBuilder: (context) => popupItems,
          onSelected: onSelected,
          child: child,
        );
      },
      cupertino: (context, platform) => CupertinoButton(
        padding: cupertinoButtonPadding,
        child: icon ?? child ?? Icon(CupertinoIcons.ellipsis_circle),
        onPressed: () => _showActionSheet(context),
      ),
    );
  }

  void _showActionSheet(BuildContext context) async {
    final localizations = MaterialLocalizations.of(context);
    final cancelLabel = _toCamelCase(localizations.cancelButtonLabel);
    final value = await showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: title,
        message: message,
        actions: itemBuilder(context)
            .map(
              (e) => _toCupertinoAction(e, context),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          child: Text(cancelLabel),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
    if (value != null && onSelected != null) {
      onSelected!(value);
    }
  }

  String _toCamelCase(String input) {
    return input[0] + input.substring(1).toLowerCase();
  }

  Widget _toCupertinoAction(
      PlatformPopupMenuEntry entry, BuildContext context) {
    if (entry is PlatformPopupMenuItem) {
      return CupertinoActionSheetAction(
        child: entry.child,
        onPressed: () {
          Navigator.pop(context, entry.value);
        },
      );
    }
    return Divider();
  }

  PopupMenuEntry<T> _toMaterialEntry(
      PlatformPopupMenuEntry<T> entry, BuildContext context) {
    if (entry is PlatformPopupMenuItem<T>) {
      return PopupMenuItem<T>(
        value: entry.value,
        child: entry.child,
      );
    }
    return PopupMenuDivider();
  }
}

class PlatformPopupMenuEntry<T> {
  const PlatformPopupMenuEntry();
}

class PlatformPopupMenuItem<T> extends PlatformPopupMenuEntry<T> {
  final Key? key;
  final T value;
  final Widget child;
  const PlatformPopupMenuItem(
      {this.key, required this.value, required this.child});
}

class PlatformPopupDivider<T> extends PlatformPopupMenuEntry<T> {
  const PlatformPopupDivider();
}
