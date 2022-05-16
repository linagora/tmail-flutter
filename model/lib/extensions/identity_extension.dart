
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/identity/identity_request_dto.dart';

extension IdentityExtension on Identity {
  EmailAddress toEmailAddressNoName() => EmailAddress(null, email);

  IdentityRequestDto toIdentityRequest() => IdentityRequestDto(
    name: name,
    replyTo: replyTo,
    bcc: bcc,
    textSignature: textSignature,
    htmlSignature: htmlSignature);
}