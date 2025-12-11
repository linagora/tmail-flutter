import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scribe/scribe/ai/presentation/styles/ai_scribe_styles.dart';
import 'package:scribe/scribe/ai/presentation/widgets/ai_scribe.dart';

void main() {
  group('calculateMenuDialogHeight::', () {
    test('should calculate correct height with content and default 4 categories', () {
      // Arrange
      const hasContent = true;
      const categoryCount = 4;

      // Act
      final height = calculateMenuDialogHeight(
        hasContent: hasContent,
        categoryCount: categoryCount,
      );

      // Assert
      // 4 categories × 40px + 8px spacing + 48px bar = 216px
      const expectedHeight = (4 * AIScribeSizes.menuItemHeight) +
          AIScribeSizes.fieldSpacing +
          AIScribeSizes.barHeight;
      expect(height, expectedHeight);
      expect(height, 216.0);
    });

    test('should calculate correct height with content and custom categories', () {
      // Arrange
      const hasContent = true;
      const categoryCount = 2;

      // Act
      final height = calculateMenuDialogHeight(
        hasContent: hasContent,
        categoryCount: categoryCount,
      );

      // Assert
      // 2 categories × 40px + 8px spacing + 48px bar = 136px
      const expectedHeight = (2 * AIScribeSizes.menuItemHeight) +
          AIScribeSizes.fieldSpacing +
          AIScribeSizes.barHeight;
      expect(height, expectedHeight);
      expect(height, 136.0);
    });

    test('should calculate correct height without content (bar only)', () {
      // Arrange
      const hasContent = false;
      const categoryCount = 4; // Should be ignored when hasContent is false

      // Act
      final height = calculateMenuDialogHeight(
        hasContent: hasContent,
        categoryCount: categoryCount,
      );

      // Assert
      // Only the bar height
      expect(height, AIScribeSizes.barHeight);
      expect(height, 48.0);
    });
  });

  group('calculateModalPosition::', () {
    testWidgets('should adjust left position when modal would go off-screen to the right', (tester) async {
      // Arrange
      const screenSize = Size(800, 600);
      const buttonPosition = Offset(700, 300); // Close to right edge
      const modalWidth = 440.0;
      BuildContext? capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: screenSize),
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return Container();
              },
            ),
          ),
        ),
      );

      // Act
      final position = calculateModalPosition(
        context: capturedContext!,
        buttonPosition: buttonPosition,
        modalWidth: modalWidth,
      );

      // Assert
      final expectedLeft = screenSize.width - modalWidth - AIScribeSizes.screenEdgePadding;
      expect(position.left, expectedLeft);
    });

    testWidgets('should adjust left position to screenEdgePadding when modal would go off-screen to the left', (tester) async {
      // Arrange
      const screenSize = Size(800, 600);
      const buttonPosition = Offset(5, 300); // Very close to left edge
      const modalWidth = 440.0;
      BuildContext? capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: screenSize),
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return Container();
              },
            ),
          ),
        ),
      );

      // Act
      final position = calculateModalPosition(
        context: capturedContext!,
        buttonPosition: buttonPosition,
        modalWidth: modalWidth,
      );

      // Assert
      expect(position.left, AIScribeSizes.screenEdgePadding);
    });

    testWidgets('should adjust bottom position when modal height is provided and would go off-screen to the top', (tester) async {
      // Arrange
      const screenSize = Size(800, 600);
      const buttonPosition = Offset(100, 50); // Close to top
      const modalWidth = 440.0;
      const modalHeight = 400.0;
      BuildContext? capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: screenSize),
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return Container();
              },
            ),
          ),
        ),
      );

      // Act
      final position = calculateModalPosition(
        context: capturedContext!,
        buttonPosition: buttonPosition,
        modalWidth: modalWidth,
        modalHeight: modalHeight,
      );

      // Assert
      final expectedBottom = screenSize.height - modalHeight - AIScribeSizes.screenEdgePadding;
      expect(position.bottom, expectedBottom);
    });

    testWidgets('should adjust bottom position to screenEdgePadding when calculated bottom is too small', (tester) async {
      // Arrange
      const screenSize = Size(800, 600);
      const buttonPosition = Offset(100, 595); // Very close to bottom edge
      const modalWidth = 440.0;
      const modalHeight = 400.0;
      BuildContext? capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: screenSize),
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return Container();
              },
            ),
          ),
        ),
      );

      // Act
      final position = calculateModalPosition(
        context: capturedContext!,
        buttonPosition: buttonPosition,
        modalWidth: modalWidth,
        modalHeight: modalHeight,
      );

      // Assert
      // bottom = 600 - 595 + 8 = 13, which is < 16, so it should be adjusted to 16
      expect(position.bottom, AIScribeSizes.screenEdgePadding);
    });
  });
}
