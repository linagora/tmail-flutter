import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/features/public_asset/domain/model/public_assets_in_identity_arguments.dart';

class IdentityCache with EquatableMixin {
  final Identity? identity;
  final IdentityActionType identityActionType;
  final bool isDefault;
  final PublicAssetsInIdentityArguments? publicAssetsInIdentityArguments;

  IdentityCache({
    required this.identity,
    required this.identityActionType,
    required this.isDefault,
    required this.publicAssetsInIdentityArguments});

  @override
  List<Object?> get props => [
    identity,
    identityActionType,
    isDefault,
    publicAssetsInIdentityArguments];
}