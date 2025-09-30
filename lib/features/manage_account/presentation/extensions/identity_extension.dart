import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
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

  IdentitySignature? toIdentitySignature() => id != null
      ? IdentitySignature(identityId: id!, signature: signatureAsString)
      : null;

  Identity asDefault() => copyWith(sortOrder: UnsignedInt(0));

  Identity copyWith({
    IdentityId? id,
    String? description,
    String? name,
    String? email,
    Set<EmailAddress>? bcc,
    Set<EmailAddress>? replyTo,
    Signature? textSignature,
    Signature? htmlSignature,
    bool? mayDelete,
    UnsignedInt? sortOrder,
  }) {
    return Identity(
      id: id ?? this.id,
      description: description ?? this.description,
      name: name ?? this.name,
      email: email ?? this.email,
      bcc: bcc ?? this.bcc,
      replyTo: replyTo ?? this.replyTo,
      textSignature: textSignature ?? this.textSignature,
      htmlSignature: htmlSignature ?? this.htmlSignature,
      mayDelete: mayDelete ?? this.mayDelete,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
