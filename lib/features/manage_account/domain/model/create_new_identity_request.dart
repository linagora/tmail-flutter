
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class CreateNewIdentityRequest with EquatableMixin {

  final Identity newIdentity;
  final Id creationId;
  final bool isDefaultIdentity;

  CreateNewIdentityRequest(
    this.creationId, 
    this.newIdentity, 
    {
      this.isDefaultIdentity = false
    });

  @override
  List<Object?> get props => [creationId, newIdentity, isDefaultIdentity];
}