
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/oidc/converter/token_id_converter.dart';
import 'package:model/oidc/token_id.dart';

part 'token_oidc.g.dart';

@TokenIdConverter()
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class TokenOIDC with EquatableMixin {

  final String token;
  final TokenId tokenId;
  final DateTime? expiredTime;
  final String refreshToken;
  final String authority;

  TokenOIDC({
    required this.token,
    required this.tokenId,
    required this.refreshToken,
    required this.authority,
    this.expiredTime
  });

  factory TokenOIDC.fromJson(Map<String, dynamic> json) => _$TokenOIDCFromJson(json);

  Map<String, dynamic> toJson() => _$TokenOIDCToJson(this);

  @override
  List<Object?> get props => [
    token,
    tokenId,
    expiredTime,
    refreshToken,
    authority
  ];
}