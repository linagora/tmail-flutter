import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

extension EmailAddressSetExtension on Set<String> {
  /// Maps a set of raw email strings to [EmailAddress] entities (no display name).
  List<EmailAddress> toEmailAddresses() =>
      map((email) => EmailAddress(null, email)).toList();
}
