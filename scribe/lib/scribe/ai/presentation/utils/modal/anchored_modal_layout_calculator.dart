import 'package:flutter/animation.dart';
import 'package:scribe/scribe/ai/presentation/model/modal/anchored_modal_layout_input.dart';
import 'package:scribe/scribe/ai/presentation/model/modal/anchored_modal_layout_result.dart';
import 'package:scribe/scribe/ai/presentation/model/modal/modal_cross_axis_alignment.dart';
import 'package:scribe/scribe/ai/presentation/model/modal/modal_placement.dart';

class AnchoredModalLayoutCalculator {
  static AnchoredModalLayoutResult calculate({
    required AnchoredModalLayoutInput input,
    double padding = 8,
    double gap = 8,
    double verticalOffset = 6,
  }) {
    final screen = input.screenSize;
    final anchor = input.anchorPosition;
    final size = input.anchorSize;
    final menu = input.menuSize;

    final fallbackOrder = [
      ModalPlacement.right,
      ModalPlacement.bottom,
      ModalPlacement.top,
      ModalPlacement.left,
    ];

    late ModalPlacement placement;

    if (input.preferredPlacement != null &&
        _canPlace(
          placement: input.preferredPlacement!,
          screen: screen,
          anchor: anchor,
          anchorSize: size,
          menu: menu,
          gap: gap,
        )) {
      placement = input.preferredPlacement!;
    } else {
      placement = fallbackOrder.firstWhere(
        (p) => _canPlace(
          placement: p,
          screen: screen,
          anchor: anchor,
          anchorSize: size,
          menu: menu,
          gap: gap,
        ),
        orElse: () => ModalPlacement.left,
      );
    }

    late double left;
    late double top;

    switch (placement) {
      case ModalPlacement.right:
        left = anchor.dx + size.width + gap;
        top = _resolveAlignedPosition(
              alignment: input.crossAxisAlignment,
              anchorStart: anchor.dy,
              anchorSize: size.height,
              menuSize: menu.height,
            ) +
            verticalOffset;
        break;

      case ModalPlacement.bottom:
        left = _resolveAlignedPosition(
          alignment: input.crossAxisAlignment,
          anchorStart: anchor.dx,
          anchorSize: size.width,
          menuSize: menu.width,
        );
        top = anchor.dy + size.height + gap + verticalOffset;
        break;

      case ModalPlacement.top:
        left = _resolveAlignedPosition(
          alignment: input.crossAxisAlignment,
          anchorStart: anchor.dx,
          anchorSize: size.width,
          menuSize: menu.width,
        );
        top = anchor.dy - menu.height - gap + verticalOffset;
        break;
      case ModalPlacement.left:
        left = anchor.dx - menu.width - gap;
        top = _resolveAlignedPosition(
              alignment: input.crossAxisAlignment,
              anchorStart: anchor.dy,
              anchorSize: size.height,
              menuSize: menu.height,
            ) +
            verticalOffset;
        break;
    }

    left = left.clamp(padding, screen.width - menu.width - padding);
    top = top.clamp(padding, screen.height - menu.height - padding);

    return AnchoredModalLayoutResult(
      position: Offset(left, top),
      placement: placement,
    );
  }

  static bool _canPlace({
    required ModalPlacement placement,
    required Size screen,
    required Offset anchor,
    required Size anchorSize,
    required Size menu,
    required double gap,
  }) {
    switch (placement) {
      case ModalPlacement.right:
        return screen.width - (anchor.dx + anchorSize.width) >=
            menu.width + gap;
      case ModalPlacement.left:
        return anchor.dx >= menu.width + gap;
      case ModalPlacement.bottom:
        return screen.height - (anchor.dy + anchorSize.height) >=
            menu.height + gap;
      case ModalPlacement.top:
        return anchor.dy >= menu.height + gap;
    }
  }

  static double _resolveAlignedPosition({
    required ModalCrossAxisAlignment alignment,
    required double anchorStart,
    required double anchorSize,
    required double menuSize,
  }) {
    switch (alignment) {
      case ModalCrossAxisAlignment.start:
        return anchorStart;
      case ModalCrossAxisAlignment.center:
        return anchorStart + anchorSize / 2 - menuSize / 2;
      case ModalCrossAxisAlignment.end:
        return anchorStart + anchorSize - menuSize;
    }
  }
}
