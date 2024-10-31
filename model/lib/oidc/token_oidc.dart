
import 'package:core/utils/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/exceptions/token_oidc_exceptions.dart';
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

  TokenOIDC(
    this.token,
    this.tokenId,
    this.refreshToken,
    {this.expiredTime}
  );

  factory TokenOIDC.fromJson(Map<String, dynamic> json) => _$TokenOIDCFromJson(json);

  Map<String, dynamic> toJson() => _$TokenOIDCToJson(this);

  factory TokenOIDC.fromUri(String uriString) {
    final uri = Uri.parse(uriString);
    final queryParams = uri.queryParameters;

    final accessToken = queryParams['access_token'];
    if (accessToken == null || accessToken.isEmpty) {
      throw AccessTokenIsNullException();
    }

    final refreshToken = queryParams['refresh_token'];
    if (refreshToken == null || refreshToken.isEmpty) {
      throw RefreshTokenIsNullException();
    }

    final idToken = queryParams['id_token'];
    if (idToken == null || idToken.isEmpty) {
      throw TokenIdIsNullException();
    }

    final expiresIn = queryParams['expires_in'];
    if (expiresIn == null || expiresIn.isEmpty) {
      throw ExpiresTimeIsNullException();
    }

    return TokenOIDC(
      accessToken,
      TokenId(idToken),
      refreshToken,
      expiredTime: DateTime.now().add(Duration(seconds: int.parse(expiresIn))),
    );
  }

  @override
  List<Object?> get props => [token, tokenId, expiredTime, refreshToken];
}

extension TokenOIDCExtension on TokenOIDC {

  bool isTokenValid() => token.isNotEmpty && tokenId.uuid.isNotEmpty;

  String get tokenIdHash => tokenId.uuid.hashCode.toString();

  bool get isExpired {
    if (expiredTime != null) {
      final now = DateTime.now();
      log('TokenOIDC::isExpired(): TIME_NOW: $now');
      log('TokenOIDC::isExpired(): EXPIRED_DATE: $expiredTime');
      return expiredTime!.isBefore(now);
    }
    return false;
  }
}