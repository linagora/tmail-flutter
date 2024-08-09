
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';

class EditDefaultIdentityRequest extends EditIdentityRequest {

  final List<IdentityId>? oldDefaultIdentityIds;

  EditDefaultIdentityRequest({
    required super.identityId, 
    required super.identityRequest,
    required super.isDefaultIdentity,
    this.oldDefaultIdentityIds,
    super.publicAssetsInIdentityArguments
  });

  @override
  List<Object?> get props => [
    ...super.props,
    oldDefaultIdentityIds
  ];
}