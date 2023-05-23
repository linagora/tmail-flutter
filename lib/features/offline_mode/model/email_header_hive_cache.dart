
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'email_header_hive_cache.g.dart';

@HiveType(typeId: CachingConstants.EMAIL_HEADER_HIVE_CACHE_ID)
class EmailHeaderHiveCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final String? name;

  @HiveField(1)
  final String? value;

  EmailHeaderHiveCache({required this.name, required this.value});

  @override
  List<Object?> get props => [name, value];
}