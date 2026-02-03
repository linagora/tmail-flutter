import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/presentation/utils/label_utils.dart';

void main() {
  group('LabelUtils.applyLabelChanges', () {
    test('should add new labels when created list is not empty', () {
      final currentLabels = <Label>[];
      final newLabel = Label(id: Id('1'), displayName: 'Work');

      LabelUtils.applyLabelChanges(
        currentLabels: currentLabels,
        created: [newLabel],
        updated: [],
        destroyedIds: [],
      );

      expect(currentLabels.length, 1);
      expect(currentLabels.first.id?.value, '1');
    });

    test(
        'should update existing label when an updated label with the same ID is provided',
        () {
      final oldLabel = Label(id: Id('1'), displayName: 'Old Name');
      final currentLabels = <Label>[oldLabel];

      final updatedLabel = Label(id: Id('1'), displayName: 'New Name');

      LabelUtils.applyLabelChanges(
        currentLabels: currentLabels,
        created: [],
        updated: [updatedLabel],
        destroyedIds: [],
      );

      expect(currentLabels.length, 1);
      expect(currentLabels.first.displayName, 'New Name');
    });

    test('should remove labels when their ID is present in destroyedIds', () {
      final currentLabels = <Label>[
        Label(id: Id('1'), displayName: 'To Delete'),
        Label(id: Id('2'), displayName: 'Keep Me'),
      ];

      LabelUtils.applyLabelChanges(
        currentLabels: currentLabels,
        created: [],
        updated: [],
        destroyedIds: [Id('1')],
      );

      expect(currentLabels.length, 1);
      expect(currentLabels.any((l) => l.id?.value == '1'), isFalse);
      expect(currentLabels.any((l) => l.id?.value == '2'), isTrue);
    });

    test('should handle create, update, and destroy operations simultaneously',
        () {
      final currentLabels = <Label>[
        Label(id: Id('1'), displayName: 'Old'),
        Label(id: Id('2'), displayName: 'Remove'),
      ];

      LabelUtils.applyLabelChanges(
        currentLabels: currentLabels,
        created: [Label(id: Id('3'), displayName: 'New')],
        updated: [Label(id: Id('1'), displayName: 'Updated')],
        destroyedIds: [Id('2')],
      );

      expect(currentLabels.length, 2);
      expect(currentLabels.any((l) => l.displayName == 'Updated'), isTrue);
      expect(currentLabels.any((l) => l.displayName == 'New'), isTrue);
      expect(currentLabels.any((l) => l.id?.value == '2'), isFalse);
    });

    test('should do nothing when all change lists are empty', () {
      final currentLabels = <Label>[
        Label(id: Id('1'), displayName: 'Existing'),
      ];

      LabelUtils.applyLabelChanges(
        currentLabels: currentLabels,
        created: [],
        updated: [],
        destroyedIds: [],
      );

      expect(currentLabels.length, 1);
      expect(currentLabels.first.displayName, 'Existing');
    });

    test(
        'should handle destroying IDs that do not exist in currentLabels gracefully',
        () {
      final currentLabels = <Label>[
        Label(id: Id('1'), displayName: 'Keep Me'),
      ];

      LabelUtils.applyLabelChanges(
        currentLabels: currentLabels,
        created: [],
        updated: [],
        destroyedIds: [Id('999')],
      );

      expect(currentLabels.length, 1);
      expect(currentLabels.first.id?.value, '1');
    });

    test(
        'should treat updated labels as new additions if they do not exist in currentLabels (Upsert behavior)',
        () {
      final currentLabels = <Label>[];
      final labelToUpdate = Label(id: Id('1'), displayName: 'Ghost Label');

      LabelUtils.applyLabelChanges(
        currentLabels: currentLabels,
        created: [],
        updated: [labelToUpdate],
        destroyedIds: [],
      );

      expect(currentLabels.length, 1);
      expect(currentLabels.first.displayName, 'Ghost Label');
    });

    test('should move updated labels to the end of the list', () {
      final currentLabels = <Label>[
        Label(id: Id('1'), displayName: 'A'),
        Label(id: Id('2'), displayName: 'B'),
        Label(id: Id('3'), displayName: 'C'),
      ];

      final updatedLabelA = Label(id: Id('1'), displayName: 'A Updated');

      LabelUtils.applyLabelChanges(
        currentLabels: currentLabels,
        created: [],
        updated: [updatedLabelA],
        destroyedIds: [],
      );

      expect(currentLabels.length, 3);
      expect(currentLabels[0].id?.value, '2');
      expect(currentLabels[1].id?.value, '3');
      expect(currentLabels[2].id?.value, '1');
      expect(currentLabels[2].displayName, 'A Updated');
    });

    test('should prioritize update over destroy if an ID appears in both lists',
        () {
      final currentLabels = <Label>[
        Label(id: Id('1'), displayName: 'Original'),
      ];

      final updatedLabel = Label(id: Id('1'), displayName: 'Revived');

      LabelUtils.applyLabelChanges(
        currentLabels: currentLabels,
        created: [],
        updated: [updatedLabel],
        destroyedIds: [Id('1')],
      );

      expect(currentLabels.length, 1);
      expect(currentLabels.first.displayName, 'Revived');
    });
  });
}
