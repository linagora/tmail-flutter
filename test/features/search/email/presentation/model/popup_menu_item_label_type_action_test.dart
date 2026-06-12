import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/popup_menu_item_label_type_action.dart';

void main() {
  final imagePaths = ImagePaths();
  final labelA = Label(id: Id('label-a'), displayName: 'Label A');
  final labelB = Label(id: Id('label-b'), displayName: 'Label B');

  group('PopupMenuItemLabelTypeAction.selectedIcon', () {
    test('returns icFilterSelected when action matches selectedAction', () {
      final action = PopupMenuItemLabelTypeAction(labelA, labelA, imagePaths);

      expect(action.selectedIcon, equals(imagePaths.icFilterSelected));
    });

    test('returns icFilterSelected when action does not match selectedAction', () {
      final action = PopupMenuItemLabelTypeAction(labelA, labelB, imagePaths);

      expect(action.selectedIcon, equals(imagePaths.icFilterSelected));
    });

    test('returns icFilterSelected when selectedAction is null', () {
      final action = PopupMenuItemLabelTypeAction(labelA, null, imagePaths);

      expect(action.selectedIcon, equals(imagePaths.icFilterSelected));
    });

    test('does not use checkbox icon for any selection state', () {
      final selectedAction = PopupMenuItemLabelTypeAction(labelA, labelA, imagePaths);
      final unselectedAction = PopupMenuItemLabelTypeAction(labelA, labelB, imagePaths);

      expect(selectedAction.selectedIcon, isNot(contains('checkbox')));
      expect(unselectedAction.selectedIcon, isNot(contains('checkbox')));
    });
  });
}
