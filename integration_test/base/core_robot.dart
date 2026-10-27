import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:patrol/patrol.dart';

import '../utils/test_timeouts.dart';
import '../utils/wait_for_condition.dart';

abstract class CoreRobot {
  final PatrolIntegrationTester $;

  CoreRobot(this.$);

  dynamic ignoreException() => $.tester.takeException();

  MobileAutomator get native => $.platformAutomator.mobile;

  // patrol_finders 3.2.0 enterText leaves its mock text input registered, which swallows every hide
  Future<void> hideKeyboard() async {
    $.tester.testTextInput.unregister();
    FocusManager.instance.primaryFocus?.unfocus();
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    final view = $.tester.view;
    await waitForCondition(
      () async {
        await $.pump();
        return view.viewInsets.bottom == 0;
      },
      timeout: TestTimeouts.short,
    );
  }
}
