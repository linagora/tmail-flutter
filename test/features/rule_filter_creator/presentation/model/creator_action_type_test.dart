import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/creator_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

void main() {
  final appLocalizations = AppLocalizations();

  group('CreatorActionType::getActionName', () {
    test('should return "Create rule" label when creating a rule', () {
      expect(
        CreatorActionType.create.getActionName(appLocalizations),
        appLocalizations.createRule,
      );
    });

    test('should return "Save" label when editing a rule', () {
      expect(
        CreatorActionType.edit.getActionName(appLocalizations),
        appLocalizations.save,
      );
    });
  });
}
