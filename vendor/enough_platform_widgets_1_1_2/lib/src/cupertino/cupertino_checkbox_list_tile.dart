import 'package:flutter/cupertino.dart';

/// A simple cupertino style checkbox list tile.
class CupertinoCheckboxListTile extends StatelessWidget {
  final bool? value;
  final void Function(bool? value)? onChanged;
  final Widget? title;
  final Widget? subtitle;
  final EdgeInsetsGeometry? contentPadding;
  final Color? activeColor;
  final Color? checkColor;
  final bool selected;

  /// Creates a new checkbox list tile with the given [value] and [onChanged] callback.
  const CupertinoCheckboxListTile({
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
    final theme = CupertinoTheme.of(context);
    final highlightColor = checkColor ??
        ((onChanged != null)
            ? (activeColor ?? theme.primaryColor)
            : (theme.barBackgroundColor));
    final box = (value == true)
        ? Icon(
            CupertinoIcons.check_mark_circled_solid,
            color: highlightColor,
          )
        : Icon(
            CupertinoIcons.circle,
            color: highlightColor,
          );
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
    if (selected) {
      content = CupertinoTheme(
        data: CupertinoThemeData(
          primaryColor: highlightColor,
          //textTheme: CupertinoTextThemeData(textStyle: CupertinoTe)),
        ),
        child: content,
      );
    }
    return GestureDetector(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: box,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      width: 1,
                      color: CupertinoTheme.of(context).barBackgroundColor),
                ),
              ),
              child: Padding(
                padding: padding,
                child: content,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        final callback = onChanged;
        if (callback != null) {
          final current = value;
          callback(current == null ? true : !current);
        }
      },
    );
  }
}
