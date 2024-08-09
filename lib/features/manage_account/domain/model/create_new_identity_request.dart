
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/public_asset/domain/model/public_assets_in_identity_arguments.dart';

class CreateNewIdentityRequest with EquatableMixin {

  final Identity newIdentity;
  final Id creationId;
  final bool isDefaultIdentity;
  final PublicAssetsInIdentityArguments? publicAssetsInIdentityArguments;

  CreateNewIdentityRequest(
    this.creationId, 
    this.newIdentity, 
    {
      this.isDefaultIdentity = false,
      this.publicAssetsInIdentityArguments,
    });

  @override
  List<Object?> get props => [creationId, newIdentity, isDefaultIdentity, publicAssetsInIdentityArguments];
}