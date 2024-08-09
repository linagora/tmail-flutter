import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/public_asset_controller.dart';

class PublicAssetsInIdentityArguments with EquatableMixin {
  final String htmlSignature;
  final List<PublicAssetId> preExistingPublicAssetIds;
  final List<PublicAssetId> newlyPickedPublicAssetIds;

  PublicAssetsInIdentityArguments({
    required this.htmlSignature,
    required this.preExistingPublicAssetIds,
    required this.newlyPickedPublicAssetIds,
  });
  
  @override
  List<Object?> get props => [
    htmlSignature,
    preExistingPublicAssetIds,
    newlyPickedPublicAssetIds,
  ];
}