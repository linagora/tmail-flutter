import 'package:flutter/animation.dart';
import 'package:scribe/scribe/ai/presentation/model/modal/modal_cross_axis_alignment.dart';
import 'package:scribe/scribe/ai/presentation/model/modal/modal_placement.dart';

class AnchoredModalLayoutInput {
  final Size screenSize;
  final Offset anchorPosition;
  final Size anchorSize;
  final Size menuSize;
  final ModalPlacement? preferredPlacement;
  final ModalCrossAxisAlignment crossAxisAlignment;

  const AnchoredModalLayoutInput({
    required this.screenSize,
    required this.anchorPosition,
    required this.anchorSize,
    required this.menuSize,
    this.preferredPlacement,
    this.crossAxisAlignment = ModalCrossAxisAlignment.center,
  });
}
