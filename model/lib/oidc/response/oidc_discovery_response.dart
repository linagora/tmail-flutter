import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'oidc_discovery_response.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OIDCDiscoveryResponse with EquatableMixin {

  final String? authorizationEndpoint;
  final String? tokenEndpoint;
  final String? endSessionEndpoint;

  OIDCDiscoveryResponse(this.authorizationEndpoint, this.tokenEndpoint, this.endSessionEndpoint);

  factory OIDCDiscoveryResponse.fromJson(Map<String, dynamic> json) => _$OIDCDiscoveryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OIDCDiscoveryResponseToJson(this);

  @override
  List<Object?> get props => [authorizationEndpoint, tokenEndpoint, endSessionEndpoint];
}