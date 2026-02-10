import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/presentation/utils/label_utils.dart';

void main() {
  Label createLabel(String id, String name) {
    return Label(id: Id(id), displayName: name);
  }

  group('LabelUtils.applyLabelChanges', () {
    group('Create Operations', () {
      test('should add new labels when created list is not empty', () {
        final currentLabels = <Label>[];
        final newLabel = createLabel('1', 'Work');

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
          'should replace existing label if the same ID appears in the created list (Overwrite/Sync Fix)',
          () {
        final currentLabels = [createLabel('1', 'Old Version')];
        final newVersionLabel = createLabel('1', 'New Version');

        LabelUtils.applyLabelChanges(
          currentLabels: currentLabels,
          created: [newVersionLabel],
          updated: [],
          destroyedIds: [],
        );

        expect(currentLabels.length, 1,
            reason: 'List should not contain duplicates');
        expect(currentLabels.first.displayName, 'New Version');
      });
    });

    group('Update Operations', () {
      test('should update existing label when provided in updated list', () {
        final currentLabels = [createLabel('1', 'Old Name')];
        final updatedLabel = createLabel('1', 'New Name');

        LabelUtils.applyLabelChanges(
          currentLabels: currentLabels,
          created: [],
          updated: [updatedLabel],
          destroyedIds: [],
        );

        expect(currentLabels.length, 1);
        expect(currentLabels.first.displayName, 'New Name');
      });

      test(
          'should treat updated labels as new additions if they do not exist (Upsert behavior)',
          () {
        final currentLabels = <Label>[];
        final labelToUpdate = createLabel('1', 'Ghost Label');

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
        final currentLabels = [
          createLabel('1', 'A'),
          createLabel('2', 'B'),
          createLabel('3', 'C'),
        ];

        final updatedLabelA = createLabel('1', 'A Updated');

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
    });

    group('Destroy Operations', () {
      test('should remove labels when their ID is present in destroyedIds', () {
        final currentLabels = [
          createLabel('1', 'To Delete'),
          createLabel('2', 'Keep Me'),
        ];

        LabelUtils.applyLabelChanges(
          currentLabels: currentLabels,
          created: [],
          updated: [],
          destroyedIds: [Id('1')],
        );

        expect(currentLabels.length, 1);
        expect(currentLabels.any((l) => l.id?.value == '1'), isFalse);
        expect(currentLabels.first.id?.value, '2');
      });

      test('should handle destroying IDs that do not exist gracefully', () {
        final currentLabels = [createLabel('1', 'Keep Me')];

        LabelUtils.applyLabelChanges(
          currentLabels: currentLabels,
          created: [],
          updated: [],
          destroyedIds: [Id('999')],
        );

        expect(currentLabels.length, 1);
        expect(currentLabels.first.id?.value, '1');
      });
    });

    group('Complex Scenarios & Edge Cases', () {
      test(
          'should handle create, update, and destroy operations simultaneously',
          () {
        final currentLabels = [
          createLabel('1', 'To Update'),
          createLabel('2', 'To Destroy'),
          createLabel('3', 'To Replace via Create'),
        ];

        LabelUtils.applyLabelChanges(
          currentLabels: currentLabels,
          created: [
            createLabel('4', 'New 4'),
            createLabel('3', 'Replaced 3'),
          ],
          updated: [
            createLabel('1', 'Updated 1'),
          ],
          destroyedIds: [Id('2')],
        );

        expect(currentLabels.length, 3);
        expect(currentLabels.any((l) => l.id?.value == '2'), isFalse);
        expect(currentLabels.any((l) => l.displayName == 'Updated 1'), isTrue);
        expect(currentLabels.any((l) => l.displayName == 'New 4'), isTrue);
        expect(currentLabels.any((l) => l.displayName == 'Replaced 3'), isTrue);
        expect(
            currentLabels.any((l) => l.displayName == 'To Replace via Create'),
            isFalse);
      });

      test('should do nothing when all change lists are empty', () {
        final currentLabels = [createLabel('1', 'Existing')];

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
          'should prioritize update over destroy if an ID appears in both lists',
          () {
        final currentLabels = [createLabel('1', 'Original')];
        final updatedLabel = createLabel('1', 'Revived');

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
  });
}
