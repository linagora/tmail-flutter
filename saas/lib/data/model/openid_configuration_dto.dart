import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/oidc/openid_configuration.dart';

part 'openid_configuration_dto.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OpenIdConfigurationDto with EquatableMixin {
  final String issuer;
  final String tokenEndpoint;
  final String endSessionEndpoint;

  OpenIdConfigurationDto({
    required this.issuer,
    required this.tokenEndpoint,
    required this.endSessionEndpoint
  });

  @override
  List<Object?> get props => [issuer, tokenEndpoint, endSessionEndpoint];

  factory OpenIdConfigurationDto.fromJson(Map<String, dynamic> json) => _$OpenIdConfigurationDtoFromJson(json);
  Map<String, dynamic> toJson() => _$OpenIdConfigurationDtoToJson(this);

  OpenIdConfiguration toOpenIdConfiguration() {
    return OpenIdConfiguration(
      issuer: issuer,
      tokenEndpoint: tokenEndpoint,
      endSessionEndpoint: endSessionEndpoint
    );
  }
}