
import 'package:flutter/material.dart';

typedef IconWebCallback = void Function();
typedef IconWebHasPositionCallback = void Function(RelativeRect);

Widget buildIconWeb({
  required Widget icon,
  String? tooltip,
  IconWebCallback? onTap,
  EdgeInsets? iconPadding,
  double? iconSize,
}) {
  return Material(
      color: Colors.transparent,
      shape: CircleBorder(),
      child: IconButton(
          icon: icon,
          iconSize: iconSize,
          padding: iconPadding ?? EdgeInsets.all(8.0),
          splashRadius: 20,
          tooltip: tooltip,
          onPressed: onTap)
  );
}

Widget buildIconWebHasPosition(BuildContext context, {
  required Widget icon,
  String? tooltip,
  IconWebHasPositionCallback? onTap
}) {
  return GestureDetector(
      onTapDown: (detail) {
        final screenSize = MediaQuery.of(context).size;
        final offset = detail.globalPosition;
        final position = RelativeRect.fromLTRB(
          offset.dx,
          offset.dy,
          screenSize.width - offset.dx,
          screenSize.height - offset.dy,
        );
        onTap?.call(position);
      },
      child: Tooltip(
        message: tooltip,
        child: icon,
      )
  );
}