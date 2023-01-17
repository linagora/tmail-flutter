
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/model.dart';

class EditIdentityRequest with EquatableMixin {

  final IdentityRequestDto identityRequest;
  final IdentityId identityId;
  final bool isDefaultIdentity;

  EditIdentityRequest({
    required this.identityId, 
    required this.identityRequest,
    this.isDefaultIdentity = false
  });

  @override
  List<Object?> get props => [
    identityId, 
    identityRequest,
    isDefaultIdentity
  ];
}