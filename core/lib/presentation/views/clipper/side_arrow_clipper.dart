import 'package:flutter/material.dart';

/// Create a custom clipper with a side arrow.
/// To help achieve various custom shapes of widget
class SideArrowClipper extends CustomClipper<Path> {
  /// Alignment
  final bool isRight;

  ///The radius, which creates the curved appearance of the widget has a default value of 16.
  final double radius;

  /// The arrow creates the curved shape of the widget and has a default arrowSize of 8.
  final double arrowSize;

  /// Offset show distance from bottom and has default value 30.
  final double offset;

  SideArrowClipper({
    this.isRight = false,
    this.radius = 16,
    this.offset = 30,
    this.arrowSize = 8
  });

  @override
  Path getClip(Size size) {
    var path = Path();

    if (isRight) {
      path.addRRect(RRect.fromLTRBR(0, 0, size.width - arrowSize, size.height, Radius.circular(radius)));

      var path2 = Path();
      path2.lineTo(arrowSize, arrowSize);
      path2.lineTo(0, 2 * arrowSize);
      path2.lineTo(0, 0);

      path.addPath(path2, Offset(size.width - arrowSize, size.height - offset - 2 * arrowSize));
    } else {
      path.addRRect(RRect.fromLTRBR(arrowSize, 0, size.width, size.height, Radius.circular(radius)));

      var path2 = Path();
      path2.lineTo(0, 2 * arrowSize);
      path2.lineTo(-arrowSize, arrowSize);
      path2.lineTo(0, 0);

      path.addPath(path2, Offset(arrowSize, size.height - offset - 2 * arrowSize));
    }

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}