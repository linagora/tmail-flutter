import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/open_insert_link_dialog_via_keyboard_shortcut_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should open custom insert-link dialog when pressing Ctrl+K / Cmd+K in the composer editor',
    scenarioBuilder: ($, robots) =>
        OpenInsertLinkDialogViaKeyboardShortcutScenario($, robots),
    tags: [TestTags.web],
  );
}
