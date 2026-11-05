import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

import '../robots/abstract/abstract_composer_robot.dart';
import 'test_timeouts.dart';
import 'wait_for_condition.dart';

/// Taps Send and returns once the send has actually resolved: either the success
/// state lands on the dashboard bus, or the failure confirm dialog appears.
///
/// The subscription is set up *before* the tap because [SendEmailSuccess] is
/// momentary and is usually emitted before the tree settles, so reading it after
/// the tap would race and miss it. A send failure never reaches this bus — it is
/// surfaced as a confirm dialog — so that dialog is the failure signal. Racing the
/// two means a failed send reports in seconds instead of burning the full timeout.
Future<void> sendAndWaitForCompletion(
  PatrolIntegrationTester $,
  AbstractComposerRobot composerRobot,
) async {
  final dashboardController = Get.find<MailboxDashBoardController>();
  var sendSucceeded = false;
  final subscription = dashboardController.viewState.stream.listen((state) {
    state.fold((_) {}, (success) {
      if (success is SendEmailSuccess) sendSucceeded = true;
    });
  });

  try {
    await composerRobot.send();
    await waitForCondition(
      () => sendSucceeded || $(#confirm_dialog_action).visible,
      timeout: TestTimeouts.long,
    );
  } finally {
    await subscription.cancel();
  }

  expect(
    $(#confirm_dialog_action).visible,
    isFalse,
    reason: 'Email failed to send: a confirm dialog is shown instead of being '
        'filed to Sent. Last texts on screen: ${_lastTexts($)}',
  );
}

// The dialog is the last route, so its message is among the last texts.
List<String> _lastTexts(PatrolIntegrationTester $) => $.tester
    .widgetList<Text>(find.byType(Text))
    .map((text) => text.data)
    .whereType<String>()
    .toList()
    .reversed
    .take(5)
    .toList();
