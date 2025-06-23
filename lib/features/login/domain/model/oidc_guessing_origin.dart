import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

enum OidcGuessingOrigin {
  empty(origin: ''),
  autoDiscover(origin: 'autodiscover'),
  jmap(origin: 'jmap');

  const OidcGuessingOrigin({required this.origin});

  final String origin;

  String url(String email) {
    if (!EmailUtils.isEmailAddressValid(email)) {
      throw ArgumentError('Invalid email address: $email');
    }
    final emailDomain = email.split('@').last;
    return switch (this) {
      OidcGuessingOrigin.empty => 'https://$emailDomain',
      _ => origin.trim().isEmpty
        ? OidcGuessingOrigin.empty.url(email)
        : 'https://$origin.$emailDomain',
    };
  }
}
