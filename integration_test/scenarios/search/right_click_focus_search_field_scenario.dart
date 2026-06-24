import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart';

import '../../base/base_test_scenario.dart';
import '../../extensions/patrol_finder_extension.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';

class RightClickFocusSearchFieldScenario extends BaseTestScenario {
  const RightClickFocusSearchFieldScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final commonRobot = robots.commonRobot();

    // The dashboard search bar only mounts once the seeded-credentials login
    // settles, so wait for the dashboard to be ready first.
    await commonRobot.waitForMailboxReady();

    final searchField = $(SearchInputFormWidget).$(TextField);
    await $.waitUntilVisible(searchField);

    // Precondition: the search field is not focused on load.
    expect(_isFocused(searchField), isFalse);

    // A secondary (right) mouse-button press should focus the field on web,
    // through the RightClickFocus wrapper introduced in linagora-design-flutter.
    await searchField.rightClick();
    await waitForCondition(
      () async => _isFocused(searchField),
      timeout: TestTimeouts.short,
    );

    expect(_isFocused(searchField), isTrue);
  }

  bool _isFocused(PatrolFinder searchField) => searchField.which<TextField>((field) => field.focusNode?.hasFocus ?? false).exists;
}
