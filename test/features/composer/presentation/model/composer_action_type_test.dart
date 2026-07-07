import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/composer_action_type.dart';

void main() {
  group('ComposerActionType::keepsComposerOpen', () {
    test('is true for actions that leave the composer open', () {
      expect(ComposerActionType.markAsImportant.keepsComposerOpen, isTrue);
      expect(ComposerActionType.requestReadReceipt.keepsComposerOpen, isTrue);
    });

    test('is false for actions that close or leave the composer', () {
      expect(ComposerActionType.saveAsDraft.keepsComposerOpen, isFalse);
      expect(ComposerActionType.saveAsTemplate.keepsComposerOpen, isFalse);
      expect(ComposerActionType.delete.keepsComposerOpen, isFalse);
    });
  });
}
