
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class EditIdentityRequest with EquatableMixin {

  final Identity newIdentity;
  final IdentityId identityId;

  EditIdentityRequest(this.identityId, this.newIdentity);

  @override
  List<Object?> get props => [identityId, newIdentity];
}