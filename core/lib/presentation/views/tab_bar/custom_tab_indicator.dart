import 'package:flutter/widgets.dart';

enum CustomIndicatorSize {
  tiny,
  normal,
  full,
}

class CustomIndicator extends Decoration {
  final double indicatorHeight;
  final Color indicatorColor;
  final CustomIndicatorSize indicatorSize;

  const CustomIndicator({
    required this.indicatorHeight,
    required this.indicatorColor,
    required this.indicatorSize
  });

  @override
  _CustomPainter createBoxPainter([VoidCallback? onChanged]) {
    return new _CustomPainter(this, onChanged);
  }
}

class _CustomPainter extends BoxPainter {
  final CustomIndicator decoration;

  _CustomPainter(this.decoration, VoidCallback? onChanged) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);

    Rect? rect;
    if (decoration.indicatorSize == CustomIndicatorSize.full) {
      rect = Offset(offset.dx,
          (configuration.size!.height - decoration.indicatorHeight)) &
      Size(configuration.size!.width, decoration.indicatorHeight);
    } else if (decoration.indicatorSize == CustomIndicatorSize.normal) {
      rect = Offset(offset.dx + 6,
          (configuration.size!.height - decoration.indicatorHeight)) &
      Size(configuration.size!.width - 12, decoration.indicatorHeight);
    } else if (decoration.indicatorSize == CustomIndicatorSize.tiny) {
      rect = Offset(offset.dx + configuration.size!.width / 2 - 8,
          (configuration.size!.height - decoration.indicatorHeight)) &
      Size(16, decoration.indicatorHeight);
    }

    if (rect != null) {
      final Paint paint = Paint();
      paint.color = decoration.indicatorColor;
      paint.style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndCorners(rect,
          topRight: Radius.circular(8),
          topLeft: Radius.circular(8)),
        paint);
    }
  }
}
