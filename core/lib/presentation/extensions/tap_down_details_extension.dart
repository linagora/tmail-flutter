
import 'package:flutter/material.dart';

extension TapDownDetailsExtension on TapDownDetails {

  RelativeRect getPosition(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final offset = globalPosition;
    final position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy,
      screenSize.width - offset.dx,
      screenSize.height - offset.dy,
    );
    return position;
  }
}