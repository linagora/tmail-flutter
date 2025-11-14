import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'oidc_discovery_response.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OIDCDiscoveryResponse with EquatableMixin {
  @JsonKey(name: 'authorization_endpoint')
  final String? authorizationEndpoint;

  @JsonKey(name: 'token_endpoint')
  final String? tokenEndpoint;

  @JsonKey(name: 'end_session_endpoint')
  final String? endSessionEndpoint;

  @JsonKey(name: 'userinfo_endpoint')
  final String? userInfoEndpoint;

  OIDCDiscoveryResponse(
    this.authorizationEndpoint,
    this.tokenEndpoint,
    this.endSessionEndpoint,
    this.userInfoEndpoint,
  );

  factory OIDCDiscoveryResponse.fromJson(Map<String, dynamic> json) =>
      _$OIDCDiscoveryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OIDCDiscoveryResponseToJson(this);

  @override
  List<Object?> get props => [
        authorizationEndpoint,
        tokenEndpoint,
        endSessionEndpoint,
        userInfoEndpoint,
      ];
}
