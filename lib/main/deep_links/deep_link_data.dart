import 'package:equatable/equatable.dart';
import 'package:model/model.dart';

class DeepLinkData with EquatableMixin {
  final String path;
  final String? accessToken;
  final String? refreshToken;
  final String? idToken;
  final int? expiresIn;
  final String? username;

  DeepLinkData({
    required this.path,
    this.accessToken,
    this.refreshToken,
    this.idToken,
    this.expiresIn,
    this.username,
  });

  bool isValidToken() => accessToken?.isNotEmpty == true && username?.isNotEmpty == true;

  TokenOIDC getTokenOIDC() {
    final expiredTime = expiresIn == null
      ? null
      : DateTime.now().add(Duration(seconds: expiresIn!));

    return TokenOIDC(
      accessToken!,
      TokenId(idToken ?? ''),
      refreshToken ?? '',
      expiredTime: expiredTime,
    );
  }

  @override
  List<Object?> get props => [
    path,
    accessToken,
    refreshToken,
    idToken,
    expiresIn,
    username,
  ];
}
