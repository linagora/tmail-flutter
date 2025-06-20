import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

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

  AccountCache(
    this.id,
    this.authenticationType,
    {
      required this.isSelected,
      this.accountId,
      this.apiUrl,
      this.userName
    }
  );

  @override
  List<Object?> get props => [
    id,
    authenticationType,
    isSelected,
    accountId,
    apiUrl,
    userName
  ];
}