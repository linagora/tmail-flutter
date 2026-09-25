import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';

/// `EmailSubmission/set` refused the envelope because it targets addresses the
/// server cannot send to.
///
/// RFC 8621 attaches the offending addresses to the SetError itself:
///
/// > invalidRecipients - The rcptTo property of the envelope (supplied or
/// > generated) contains at least one rcptTo value, which is not a valid email
/// > address for sending to. An invalidRecipients String[] property MUST also
/// > be present on the SetError, which is a list of the invalid addresses.
///
/// `SetError` does not model that property, so it is read back from the raw
/// method response and carried here for the composer to highlight.
class InvalidRecipientsException extends SetMethodException {
  final Set<String> invalidRecipients;

  /// Email/set created it before the submission was refused; the composer
  /// deletes it in the background so a resend does not leave a duplicate.
  final EmailId? createdEmailId;

  InvalidRecipientsException(
    super.mapErrors,
    this.invalidRecipients, {
    this.createdEmailId,
  });

  @override
  String get exceptionName => 'InvalidRecipientsException';

  @override
  List<Object?> get props => [...super.props, invalidRecipients, createdEmailId];
}
