import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';

import '../../extensions/patrol_finder_extension.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';
import '../search_robot.dart';

class WebResponsiveSearchRobot extends SearchRobot {
  WebResponsiveSearchRobot(super.$);

  @override
  Future<void> tapOnSearchField() async {
    await super.tapOnSearchField();
    await waitForCondition(
      () async => $(SearchEmailView).evaluate().isNotEmpty,
      timeout: TestTimeouts.short,
    );
  }

  @override
  Future<void> enterKeyword(String keyword) async {
    final finder = $(SearchEmailView).$(TextField);
    await finder.tap();
    return finder.enterTextWithoutTapAction(keyword);
  }
}
