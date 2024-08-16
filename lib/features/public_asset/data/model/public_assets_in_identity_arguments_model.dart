import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/public_asset/domain/model/public_assets_in_identity_arguments.dart';

part 'public_assets_in_identity_arguments_model.g.dart';

@JsonSerializable(converters: [IdConverter()])
class PublicAssetsInIdentityArgumentsModel extends PublicAssetsInIdentityArguments {
  PublicAssetsInIdentityArgumentsModel({
    required super.htmlSignature,
    required super.preExistingPublicAssetIds,
    required super.newlyPickedPublicAssetIds});

  factory PublicAssetsInIdentityArgumentsModel.fromJson(Map<String, dynamic> json) 
    => _$PublicAssetsInIdentityArgumentsModelFromJson(json);

  Map<String, dynamic> toJson() => _$PublicAssetsInIdentityArgumentsModelToJson(this);
  
  factory PublicAssetsInIdentityArgumentsModel.fromDomain(
    PublicAssetsInIdentityArguments publicAssetsInIdentityArguments
  ) {
    return PublicAssetsInIdentityArgumentsModel(
      htmlSignature: publicAssetsInIdentityArguments.htmlSignature,
      preExistingPublicAssetIds: publicAssetsInIdentityArguments.preExistingPublicAssetIds,
      newlyPickedPublicAssetIds: publicAssetsInIdentityArguments.newlyPickedPublicAssetIds
    );
  }
}