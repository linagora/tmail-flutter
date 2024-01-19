import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';

part 'token_response.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class TokenResponse with EquatableMixin {
  @JsonKey(name: 'access_token')
  final String? accessToken;

  @JsonKey(name: 'refresh_token')
  final String? refreshToken;

  @JsonKey(name: 'expires_in')
  final DateTime? expiredTime;

  @JsonKey(name: 'id_token')
  final String? idToken;

  TokenResponse({
    this.accessToken,
    this.refreshToken,
    this.expiredTime,
    this.idToken,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) => _$TokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TokenResponseToJson(this);

  @override
  List<Object?> get props => [accessToken, refreshToken, expiredTime, idToken];

  TokenOIDC toTokenOidc({required String authority}) => TokenOIDC(
    accessToken!,
    TokenId(idToken!),
    refreshToken!,
    expiredTime: expiredTime,
    authority: authority,
  );
}