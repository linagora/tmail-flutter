import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/presentation/utils/label_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testStyle = TextStyle(
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    fontSize: 11,
    height: 14 / 11,
  );

  const itemSpacing = 12.0;
  const horizontalPadding = 4.0;

  Label label(String name) => Label(displayName: name);

  group('LabelUtils.computeDisplayedTags', () {
    test('returns empty result when tag list is empty', () {
      final result = LabelUtils.computeDisplayedTags(
        tags: [],
        maxWidth: 200,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 40,
      );

      expect(result.displayed, isEmpty);
      expect(result.hiddenCount, 0);
    });

    test('displays a single tag when it fits within max width', () {
      final result = LabelUtils.computeDisplayedTags(
        tags: [label('Completed')],
        maxWidth: 60,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 60,
      );

      expect(result.displayed.length, 1);
      expect(result.displayed.first.safeDisplayName, 'Completed');
      expect(result.hiddenCount, 0);
    });

    test('shows first tag when single tag does not fit', () {
      final result = LabelUtils.computeDisplayedTags(
        tags: [label('Completed')],
        maxWidth: 59,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 60,
      );

      expect(result.displayed.single.safeDisplayName, 'Completed');
      expect(result.hiddenCount, 0);
    });

    test('displays all tags when both fit without overflow', () {
      final result = LabelUtils.computeDisplayedTags(
        tags: [label('A'), label('B')],
        maxWidth: 100,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 40,
      );

      expect(
        result.displayed.map((e) => e.safeDisplayName),
        ['A', 'B'],
      );
      expect(result.hiddenCount, 0);
    });

    test('shows first tag when others overflow immediately', () {
      final result = LabelUtils.computeDisplayedTags(
        tags: [label('Completed'), label('Action'), label('Info')],
        maxWidth: 50,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 40,
      );

      expect(
        result.displayed.map((e) => e.safeDisplayName),
        ['Completed'],
      );
      expect(result.hiddenCount, 2);
    });

    test('shows only first tag when +N does not fit', () {
      final result = LabelUtils.computeDisplayedTags(
        tags: [label('A'), label('B'), label('C')],
        maxWidth: 20,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 40,
      );

      expect(result.displayed.single.safeDisplayName, 'A');
      expect(result.hiddenCount, 2);
    });

    test('shows first tag when no tag fits at all', () {
      final result = LabelUtils.computeDisplayedTags(
        tags: [label('Completed'), label('Action')],
        maxWidth: 10,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 50,
      );

      expect(result.displayed.single.safeDisplayName, 'Completed');
      expect(result.hiddenCount, 1);
    });

    test('shrinks down until first tag and +N fit if possible', () {
      final result = LabelUtils.computeDisplayedTags(
        tags: [label('Completed'), label('Action'), label('Information')],
        maxWidth: 92,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 40,
      );

      expect(
        result.displayed.map((e) => e.safeDisplayName),
        ['Completed', '+2'],
      );
      expect(result.hiddenCount, 2);
    });

    test('shows all tags when max width allows full rendering', () {
      final result = LabelUtils.computeDisplayedTags(
        tags: [label('Completed'), label('Action'), label('Information')],
        maxWidth: 999,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 100,
      );

      expect(result.displayed.length, 3);
      expect(result.hiddenCount, 0);
    });

    test('falls back to first tag when second tag is too long', () {
      final result = LabelUtils.computeDisplayedTags(
        tags: [label('Completed'), label('LONG TEXT'), label('A')],
        maxWidth: 60,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (label) =>
            label.safeDisplayName == 'Completed' ? 50 : 200,
      );

      expect(result.displayed.single.safeDisplayName, 'Completed');
      expect(result.hiddenCount, 2);
    });

    test('still only shows first tag when shrinking cannot allow +N', () {
      final result = LabelUtils.computeDisplayedTags(
        tags: [label('Completed'), label('Action'), label('Information')],
        maxWidth: 90,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 60,
      );

      expect(result.displayed.single.safeDisplayName, 'Completed');
      expect(result.hiddenCount, 2);
    });

    test('shows first tag when +N exactly matches max width', () {
      final tags = List.generate(4, (i) => label('T$i'));

      final result = LabelUtils.computeDisplayedTags(
        tags: tags,
        maxWidth: 30,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 30,
      );

      expect(result.displayed.single.safeDisplayName, 'T0');
      expect(result.hiddenCount, 3);
    });

    test('shows first tag and +N when both fit', () {
      final result = LabelUtils.computeDisplayedTags(
        tags: [label('Completed'), label('Action'), label('Info')],
        maxWidth: 100,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (label) => label.safeDisplayName == 'Completed' ? 40 : 30,
      );

      expect(
        result.displayed.map((e) => e.safeDisplayName),
        ['Completed', '+2'],
      );
      expect(result.hiddenCount, 2);
    });

    test('shows only first tag when shrink still exceeds max width', () {
      final result = LabelUtils.computeDisplayedTags(
        tags: [label('Completed'), label('Action'), label('Info')],
        maxWidth: 39,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 40,
      );

      expect(result.displayed.single.safeDisplayName, 'Completed');
      expect(result.hiddenCount, 2);
    });

    test('handles large hidden counts correctly using +N logic', () {
      final tags = List.generate(50, (i) => label('Tag$i'));

      final result = LabelUtils.computeDisplayedTags(
        tags: tags,
        maxWidth: 999,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 500,
      );

      expect(result.displayed.single.safeDisplayName, 'Tag0');
      expect(result.hiddenCount, 49);
    });

    test('treats null displayName as empty and keeps first tag', () {
      final tags = [
        Label(displayName: null),
        Label(displayName: 'A'),
      ];

      final result = LabelUtils.computeDisplayedTags(
        tags: tags,
        maxWidth: 50,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (label) => label.safeDisplayName.isEmpty ? 10 : 40,
      );

      expect(result.displayed.single.safeDisplayName, '');
      expect(result.hiddenCount, 1);
    });

    test('correctly fits tags when spacing is zero', () {
      final tags = [label('A'), label('B'), label('C')];

      final result = LabelUtils.computeDisplayedTags(
        tags: tags,
        maxWidth: 80,
        textStyle: testStyle,
        itemSpacing: 0,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 40,
      );

      expect(
        result.displayed.map((e) => e.safeDisplayName),
        ['A', '+2'],
      );
      expect(result.hiddenCount, 2);
    });

    test('handles RTL labels the same as LTR while keeping first tag', () {
      final tags = [
        label('שלום'),
        label('مرحبا'),
        label('Hello'),
      ];

      final result = LabelUtils.computeDisplayedTags(
        tags: tags,
        maxWidth: 80,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 40,
      );

      expect(result.displayed.single.safeDisplayName, 'שלום');
      expect(result.hiddenCount, 2);
    });

    test('shows first tag when first label is extremely long', () {
      final tags = [
        label('THIS_IS_A_VERY_LONG_LABEL_THAT_WILL_NEVER_FIT'),
        label('A'),
        label('B'),
      ];

      final result = LabelUtils.computeDisplayedTags(
        tags: tags,
        maxWidth: 60,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (label) =>
            label.safeDisplayName.startsWith('THIS') ? 500 : 40,
      );

      expect(result.displayed.single.safeDisplayName,
          'THIS_IS_A_VERY_LONG_LABEL_THAT_WILL_NEVER_FIT');
      expect(result.hiddenCount, 2);
    });

    test('computes remaining count correctly with mixed label widths', () {
      final tags = [
        label('A'),
        label('BBBB'),
        label('CC'),
        label('DDDDDD'),
      ];

      final result = LabelUtils.computeDisplayedTags(
        tags: tags,
        maxWidth: 95,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (label) {
          switch (label.safeDisplayName.length) {
            case 1:
              return 30;
            case 2:
              return 40;
            case 4:
              return 60;
            default:
              return 100;
          }
        },
      );

      expect(result.displayed.first.safeDisplayName, 'A');
      expect(result.hiddenCount, 3);
    });

    test('shows first tag when both tag and +1 cannot fit', () {
      final result = LabelUtils.computeDisplayedTags(
        tags: [label('A')],
        maxWidth: 10,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 20,
      );

      expect(result.displayed.single.safeDisplayName, 'A');
      expect(result.hiddenCount, 0);
    });

    test('handles duplicate labels consistently and keeps first tag', () {
      final tags = [
        label('A'),
        label('A'),
        label('A'),
      ];

      final result = LabelUtils.computeDisplayedTags(
        tags: tags,
        maxWidth: 45,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 40,
      );

      expect(result.displayed.single.safeDisplayName, 'A');
      expect(result.hiddenCount, 2);
    });

    test('safeComputeDisplayedTags falls back gracefully on exception', () {
      final result = LabelUtils.safeComputeDisplayedTags(
        tags: [Label(displayName: 'A'), Label(displayName: 'B')],
        maxWidth: 100,
        textStyle: const TextStyle(),
        measureWidth: (_) => throw Exception('boom'),
      );

      expect(result.displayed.single.safeDisplayName, 'A');
      expect(result.hiddenCount, 1);
    });

    test('respects tagMaxWidth by clamping oversized label width', () {
      final tags = [
        label('SUPER_LONG_TAG_NAME'),
        label('B'),
        label('C'),
      ];

      final result = LabelUtils.computeDisplayedTags(
        tags: tags,
        maxWidth: 80,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        tagMaxWidth: 40,
        measureWidth: (_) => 200,
      );

      expect(result.displayed.single.safeDisplayName, 'SUPER_LONG_TAG_NAME');
      expect(result.hiddenCount, 2);
    });

    test('respects plusMaxWidth to prevent +N from exceeding layout', () {
      final tags = [
        label('A'),
        label('B'),
        label('C'),
        label('D'),
      ];

      final result = LabelUtils.computeDisplayedTags(
        tags: tags,
        maxWidth: 62,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        plusMaxWidth: 20,
        measureWidth: (label) =>
            label.safeDisplayName.startsWith('+') ? 50 : 30,
      );

      expect(
        result.displayed.map((e) => e.safeDisplayName),
        ['A', '+3'],
      );
      expect(result.hiddenCount, 3);
    });

    test('performs efficiently with 1k labels', () {
      final tags = List.generate(1000, (i) => label('Tag$i'));

      final watch = Stopwatch()..start();

      final result = LabelUtils.computeDisplayedTags(
        tags: tags,
        maxWidth: 300,
        textStyle: testStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        measureWidth: (_) => 30,
      );

      watch.stop();

      expect(result.displayed.isNotEmpty, true);
      expect(result.hiddenCount, greaterThan(0));

      expect(
        watch.elapsedMilliseconds < 50,
        true,
        reason: 'computeDisplayedTags took too long',
      );
    });
  });
}
