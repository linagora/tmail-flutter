import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scribe/scribe/ai/presentation/model/modal/anchored_modal_layout_input.dart';
import 'package:scribe/scribe/ai/presentation/model/modal/modal_placement.dart';
import 'package:scribe/scribe/ai/presentation/utils/modal/anchored_modal_layout_calculator.dart';

void main() {
  const screen = Size(800, 600);
  const menuSize = Size(300, 200);
  const anchorSize = Size(24, 24);

  group('AnchoredModalLayoutCalculator – placement strategy', () {
    test('places menu to the RIGHT when there is enough horizontal space', () {
      final result = AnchoredModalLayoutCalculator.calculate(
        input: const AnchoredModalLayoutInput(
          screenSize: screen,
          anchorPosition: Offset(100, 200),
          anchorSize: anchorSize,
          menuSize: menuSize,
        ),
      );

      expect(result.placement, ModalPlacement.right);
      expect(result.position.dx, greaterThan(100));
    });

    test(
        'places menu at the BOTTOM when right space is insufficient but bottom has enough space',
        () {
      final result = AnchoredModalLayoutCalculator.calculate(
        input: const AnchoredModalLayoutInput(
          screenSize: screen,
          anchorPosition: Offset(750, 200),
          anchorSize: anchorSize,
          menuSize: menuSize,
        ),
      );

      expect(result.placement, ModalPlacement.bottom);
      expect(result.position.dy, greaterThan(200));
    });

    test(
        'places menu at the TOP when right and bottom space are insufficient but top has space',
        () {
      final result = AnchoredModalLayoutCalculator.calculate(
        input: const AnchoredModalLayoutInput(
          screenSize: screen,
          anchorPosition: Offset(750, 500),
          anchorSize: anchorSize,
          menuSize: menuSize,
        ),
      );

      expect(result.placement, ModalPlacement.top);
      expect(result.position.dy, lessThan(500));
    });

    test(
        'places menu to the LEFT when neither top nor bottom has enough vertical space',
        () {
      final result = AnchoredModalLayoutCalculator.calculate(
        input: const AnchoredModalLayoutInput(
          screenSize: Size(800, 260),
          anchorPosition: Offset(750, 120),
          anchorSize: anchorSize,
          menuSize: menuSize,
        ),
      );

      expect(result.placement, ModalPlacement.left);
      expect(result.position.dx, lessThan(750));
    });

    test('falls back to LEFT placement when no direction has sufficient space',
        () {
      final result = AnchoredModalLayoutCalculator.calculate(
        input: const AnchoredModalLayoutInput(
          screenSize: Size(320, 480),
          anchorPosition: Offset(150, 200),
          anchorSize: anchorSize,
          menuSize: Size(300, 400),
        ),
      );

      expect(result.placement, ModalPlacement.left);
    });
  });

  group('AnchoredModalLayoutCalculator – screen clamping', () {
    test('clamps LEFT position to screen padding', () {
      final result = AnchoredModalLayoutCalculator.calculate(
        input: const AnchoredModalLayoutInput(
          screenSize: screen,
          anchorPosition: Offset(5, 200),
          anchorSize: anchorSize,
          menuSize: menuSize,
        ),
        padding: 16,
      );

      expect(result.position.dx, greaterThanOrEqualTo(16));
    });

    test('clamps TOP position to screen padding', () {
      final result = AnchoredModalLayoutCalculator.calculate(
        input: const AnchoredModalLayoutInput(
          screenSize: screen,
          anchorPosition: Offset(200, 5),
          anchorSize: anchorSize,
          menuSize: menuSize,
        ),
        padding: 16,
      );

      expect(result.position.dy, greaterThanOrEqualTo(16));
    });

    test('does not overflow RIGHT screen edge', () {
      final result = AnchoredModalLayoutCalculator.calculate(
        input: const AnchoredModalLayoutInput(
          screenSize: screen,
          anchorPosition: Offset(780, 200),
          anchorSize: anchorSize,
          menuSize: menuSize,
        ),
        padding: 16,
      );

      expect(
        result.position.dx + menuSize.width,
        lessThanOrEqualTo(screen.width - 16),
      );
    });

    test('does not overflow BOTTOM screen edge', () {
      final result = AnchoredModalLayoutCalculator.calculate(
        input: const AnchoredModalLayoutInput(
          screenSize: screen,
          anchorPosition: Offset(200, 580),
          anchorSize: anchorSize,
          menuSize: menuSize,
        ),
        padding: 16,
      );

      expect(
        result.position.dy + menuSize.height,
        lessThanOrEqualTo(screen.height - 16),
      );
    });
  });
}
