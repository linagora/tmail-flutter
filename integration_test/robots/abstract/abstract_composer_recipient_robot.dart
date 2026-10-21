import 'package:model/email/prefix_email_address.dart';

import 'abstract_composer_recipient_assertion_robot.dart';

abstract class AbstractComposerRecipientRobot {
  AbstractComposerRecipientAssertionRobot get assertion;

  Future<void> openCcField();

  /// Types [email] into the [prefix] field and submits it as a chip.
  Future<void> enterRecipient(PrefixEmailAddress prefix, String email);

  /// Adds chips to the [prefix] field until the free width after the last
  /// chip on its line is at least [minGap] and below [maxGap].
  Future<void> enterRecipientsUntilLineGap(
    PrefixEmailAddress prefix, {
    required double minGap,
    required double maxGap,
  });

  Future<void> tapRecipientInput(PrefixEmailAddress prefix);
}
