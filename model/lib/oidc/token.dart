
import 'package:core/utils/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:model/oidc/token_id.dart';

class Token with EquatableMixin {

  final String token;
  final TokenId tokenId;
  final String refreshToken;
  final DateTime? expiredTime;

  const Token(this.token, this.tokenId, this.refreshToken, {this.expiredTime});

  @override
  List<Object?> get props => [token, tokenId, refreshToken, expiredTime];
}

extension TokenExtension on Token {
  bool isTokenValid() => token.isNotEmpty && tokenId.uuid.isNotEmpty;

  bool get isExpired {
    if (expiredTime != null) {
      final now = DateTime.now();
      log('TokenExtension::isExpired(): TIME_NOW: $now');
      log('TokenExtension::isExpired(): EXPIRED_DATE: $expiredTime');
      return expiredTime!.isBefore(now);
    }
    return false;
  }

  String get tokenIdHash => tokenId.uuid.hashCode.toString();
}