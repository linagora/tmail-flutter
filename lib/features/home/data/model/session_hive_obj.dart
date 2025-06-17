import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'session_hive_obj.g.dart';

@HiveType(typeId: CachingConstants.SESSION_HIVE_CACHE_ID)
class SessionHiveObj extends HiveObject with EquatableMixin {

  static const String keyValue = 'session';

  @HiveField(0)
  final String value;

  SessionHiveObj({
    required this.value
  });

  @override
  List<Object?> get props => [value];
}