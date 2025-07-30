import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class IdentitySignature with EquatableMixin {
  final IdentityId identityId;
  final String signature;

  IdentitySignature({required this.identityId, required this.signature});

  IdentitySignature newSignature(String newSignature) {
    return IdentitySignature(
      identityId: identityId,
      signature: newSignature
    );
  }

  @override
  List<Object> get props => [identityId, signature];
}
