
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/model.dart';

class EditIdentityRequest with EquatableMixin {

  final IdentityRequestDto identityRequest;
  final IdentityId identityId;

  EditIdentityRequest({required this.identityId, required this.identityRequest});

  @override
  List<Object?> get props => [identityId, identityRequest];
}