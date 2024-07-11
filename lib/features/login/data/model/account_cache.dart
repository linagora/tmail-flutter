import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/login/data/model/basic_auth_cache.dart';
import 'package:tmail_ui_user/features/login/data/model/token_oidc_cache.dart';

part 'account_cache.g.dart';

@HiveType(typeId: CachingConstants.ACCOUNT_HIVE_CACHE_IDENTIFY)
class AccountCache extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String authenticationType;

  @HiveField(2)
  final bool isSelected;

  @HiveField(3)
  final String? accountId;

  @HiveField(4)
  final String? apiUrl;

  @HiveField(5)
  final String? userName;

  @HiveField(6)
  final String baseUrl;

  @HiveField(7)
  final BasicAuthCache? basicAuth;

  @HiveField(8)
  final TokenOidcCache? tokenOidc;

  AccountCache({
    required this.id,
    required this.authenticationType,
    required this.isSelected,
    required this.baseUrl,
    this.accountId,
    this.apiUrl,
    this.userName,
    this.basicAuth,
    this.tokenOidc,
  });

  @override
  List<Object?> get props => [
    id,
    authenticationType,
    isSelected,
    baseUrl,
    accountId,
    apiUrl,
    userName,
    basicAuth,
    tokenOidc,
  ];
}