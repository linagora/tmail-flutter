
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/public_asset/domain/model/public_assets_in_identity_arguments.dart';

class EditIdentityRequest with EquatableMixin {

  final IdentityRequestDto identityRequest;
  final IdentityId identityId;
  final bool isDefaultIdentity;
  final PublicAssetsInIdentityArguments? publicAssetsInIdentityArguments;
  final bool isSetAsDefault;

  EditIdentityRequest({
    required this.identityId, 
    required this.identityRequest,
    this.isDefaultIdentity = false,
    this.isSetAsDefault = false,
    this.publicAssetsInIdentityArguments
  });

  factory EditIdentityRequest.fromIdentityWithoutPublicAssets(
    Identity identity,
  ) {
    return EditIdentityRequest(
      identityId: identity.id!,
      identityRequest: identity.toIdentityRequest(),
      isDefaultIdentity: true,
      isSetAsDefault: true,
    );
  }

  @override
  List<Object?> get props => [
    identityId, 
    identityRequest,
    isDefaultIdentity,
    publicAssetsInIdentityArguments,
    isSetAsDefault,
  ];
}