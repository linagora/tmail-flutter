import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/public_asset_controller.dart';

class PublicAssetsInIdentityArguments with EquatableMixin {
  final String htmlSignature;
  final List<PublicAssetId> oldPublicAssetIds;
  final List<PublicAssetId> newPublicAssetIds;
  final IdentityActionType identityActionType;

  PublicAssetsInIdentityArguments({
    required this.htmlSignature,
    required this.oldPublicAssetIds,
    required this.newPublicAssetIds,
    required this.identityActionType
  });
  
  @override
  List<Object?> get props => [
    htmlSignature,
    oldPublicAssetIds,
    newPublicAssetIds,
    identityActionType
  ];
}