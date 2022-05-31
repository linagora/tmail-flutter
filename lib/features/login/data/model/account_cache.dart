import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
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

  AccountCache(this.id, this.authenticationType, {required this.isSelected});

  @override
  List<Object?> get props => [id, authenticationType, isSelected];
}