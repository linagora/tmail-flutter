import 'package:model/email/prefix_email_address.dart';

abstract class AbstractComposerRecipientAssertionRobot {
  /// The input starts a new line below the last chip.
  void expectRecipientInputOnOwnLine(PrefixEmailAddress prefix);
  void expectRecipientInputFocused(PrefixEmailAddress prefix);
  Future<void> expectRecipientVisible(PrefixEmailAddress prefix, String email);
}
