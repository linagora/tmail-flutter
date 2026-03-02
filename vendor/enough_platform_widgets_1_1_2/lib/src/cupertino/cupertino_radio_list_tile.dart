import 'package:flutter/cupertino.dart';

/// A simple cupertino style readio list tile.
class CupertinoRadioListTile<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final void Function(T? value)? onChanged;
  final Widget? title;
  final Widget? subtitle;
  final EdgeInsetsGeometry? contentPadding;
  final Color? activeColor;
  final bool toggable;

  /// Creates a new radio list tile with the given [value], [groupValue] and [onChanged] callback.
  ///
  /// This control is deemed selected when the value is the same as the group value.
  /// When you set [toggable] to `true` the value of a selected element can be reset to null.
  const CupertinoRadioListTile({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.contentPadding,
    this.activeColor,
    this.toggable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final highlightColor = (onChanged != null)
        ? (activeColor ?? theme.primaryColor)
        : (theme.barBackgroundColor);
    final padding = contentPadding ?? EdgeInsets.all(8.0);
    final t = title;
    final st = subtitle;
    var content = t != null && st != null
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [t, st],
          )
        : t != null
            ? t
            : st != null
                ? st
                : Container();
    return GestureDetector(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: CupertinoTheme.of(context).barBackgroundColor,
                  ),
                ),
              ),
              child: Padding(
                padding: padding,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      primaryColor: CupertinoColors.label,
                      // textStyle: TextStyle(color: CupertinoColors.label),
                    ),
                  ),
                  child: content,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Opacity(
              opacity: (value == groupValue) ? 1.0 : 0.0,
              child: Icon(
                CupertinoIcons.check_mark,
                color: highlightColor,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        final callback = onChanged;
        if (callback != null) {
          callback((value != null && toggable) ? null : value);
        }
      },
    );
  }
}
