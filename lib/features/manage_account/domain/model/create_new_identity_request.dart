
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class CreateNewIdentityRequest with EquatableMixin {

  final Identity newIdentity;
  final Id creationId;

  CreateNewIdentityRequest(this.creationId, this.newIdentity);

  @override
  List<Object?> get props => [creationId, newIdentity];
}