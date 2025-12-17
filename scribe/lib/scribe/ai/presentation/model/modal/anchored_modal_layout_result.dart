import 'package:flutter/animation.dart';
import 'package:scribe/scribe/ai/presentation/model/modal/modal_placement.dart';

class AnchoredModalLayoutResult {
  final Offset position;
  final ModalPlacement placement;

  const AnchoredModalLayoutResult({
    required this.position,
    required this.placement,
  });
}
