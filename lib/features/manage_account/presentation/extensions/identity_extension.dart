
import 'package:jmap_dart_client/jmap/identities/identity.dart';

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
}