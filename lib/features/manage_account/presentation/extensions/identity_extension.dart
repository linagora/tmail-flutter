
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identity_signature.dart';

extension IdentityExtension on Identity {

  String get signatureAsString {
    if (htmlSignature?.value.isNotEmpty == true) {
      return htmlSignature!.value;
    } else if (textSignature?.value.isNotEmpty == true) {
      return textSignature!.value;
    } else {
      return '';
    }
  }

  IdentitySignature toIdentitySignature() => IdentitySignature(
    identityId: id!,
    signature: signatureAsString,
  );
}