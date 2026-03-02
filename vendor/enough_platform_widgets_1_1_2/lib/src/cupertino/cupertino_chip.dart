import 'package:flutter/cupertino.dart';

/// A cupertino version of the material `Chip` widget
class CupertinoChip extends StatelessWidget {
  final Widget label;
  final Widget? deleteIcon;
  final void Function()? onDeleted;
  const CupertinoChip({
    Key? key,
    required this.label,
    this.deleteIcon,
    this.onDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final delIcon = deleteIcon;
    final content = delIcon != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              label,
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: delIcon,
                onPressed: onDeleted,
              ),
            ],
          )
        : label;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: content,
        ),
      ),
    );
  }
}

class CupertinoActionChip extends StatelessWidget {
  const CupertinoActionChip(
      {Key? key, required this.label, required this.onPressed})
      : super(key: key);

  final Widget label;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: CupertinoChip(
          label: label,
        ),
      ),
      onTap: onPressed,
    );
  }
}
