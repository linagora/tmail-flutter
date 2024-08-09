
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';

class CreateNewDefaultIdentityRequest extends CreateNewIdentityRequest {

  final List<IdentityId>? oldDefaultIdentityIds;

  CreateNewDefaultIdentityRequest(
    super.creationId, 
    super.newIdentity, 
    {
      this.oldDefaultIdentityIds,
      super.publicAssetsInIdentityArguments,
    });

  @override
  List<Object?> get props => [
      ...super.props, 
      oldDefaultIdentityIds];
}