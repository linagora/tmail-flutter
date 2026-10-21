import 'package:model/email/prefix_email_address.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/abstract/abstract_composer_recipient_robot.dart';

class AddRecipientWhenChipsFillLineScenario extends BaseTestScenario {
  const AddRecipientWhenChipsFillLineScenario(super.$, super.robots);

  static const _prefix = PrefixEmailAddress.cc;
  static const _newRecipient = 'new-recipient@example.org';
  // A nearly full line: wide enough for the former 20 px minimum input
  // width to keep a thin input there.
  static const _nearlyFullLineMinGap = 20.0;
  static const _nearlyFullLineMaxGap = 100.0;

  @override
  Future<void> runTestLogic() async {
    await robots.commonRobot().waitForMailboxReady();
    final composerRobot = robots.composerRobot();
    final recipientRobot = composerRobot.recipient;
    await robots.threadRobot().openComposer();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    await _stepFillCcLineThenLeaveIt(recipientRobot);
    _expectCcInputOnOwnLine(recipientRobot);

    await recipientRobot.tapRecipientInput(_prefix);
    _expectCcInputFocused(recipientRobot);
    await recipientRobot.enterRecipient(_prefix, _newRecipient);
    await _expectNewRecipientAdded(recipientRobot);
  }

  /// Nearly fills the Cc line, then moves focus to To so Cc is unfocused
  /// but stays expanded.
  Future<void> _stepFillCcLineThenLeaveIt(
    AbstractComposerRecipientRobot recipientRobot,
  ) async {
    await recipientRobot.openCcField();
    await recipientRobot.enterRecipientsUntilLineGap(
      _prefix,
      minGap: _nearlyFullLineMinGap,
      maxGap: _nearlyFullLineMaxGap,
    );
    await recipientRobot.tapRecipientInput(PrefixEmailAddress.to);
  }

  void _expectCcInputOnOwnLine(AbstractComposerRecipientRobot recipientRobot) =>
      recipientRobot.assertion.expectRecipientInputOnOwnLine(_prefix);

  void _expectCcInputFocused(AbstractComposerRecipientRobot recipientRobot) =>
      recipientRobot.assertion.expectRecipientInputFocused(_prefix);

  Future<void> _expectNewRecipientAdded(AbstractComposerRecipientRobot recipientRobot) =>
      recipientRobot.assertion.expectRecipientVisible(_prefix, _newRecipient);
}
