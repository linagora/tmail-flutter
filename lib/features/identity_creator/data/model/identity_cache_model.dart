import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/model/identity_cache.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/features/public_asset/data/model/public_assets_in_identity_arguments_model.dart';

part 'identity_cache_model.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class IdentityCacheModel extends IdentityCache {
  IdentityCacheModel({
    required super.identity,
    required super.identityActionType,
    required super.isDefault,
    required this.publicAssetsInIdentityArgumentsModel})
    : super(publicAssetsInIdentityArguments: publicAssetsInIdentityArgumentsModel);

  final PublicAssetsInIdentityArgumentsModel? publicAssetsInIdentityArgumentsModel;

  factory IdentityCacheModel.fromJson(Map<String, dynamic> json) 
    => _$IdentityCacheModelFromJson(json);

  Map<String, dynamic> toJson() => _$IdentityCacheModelToJson(this);

  factory IdentityCacheModel.fromDomain(IdentityCache identityCache) {
    return IdentityCacheModel(
      identity: identityCache.identity,
      identityActionType: identityCache.identityActionType,
      isDefault: identityCache.isDefault,
      publicAssetsInIdentityArgumentsModel: identityCache.publicAssetsInIdentityArguments == null
        ? null
        : PublicAssetsInIdentityArgumentsModel.fromDomain(identityCache.publicAssetsInIdentityArguments!)
    );
  }
}