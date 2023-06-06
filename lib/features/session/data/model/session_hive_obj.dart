import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'session_hive_obj.g.dart';

@HiveType(typeId: CachingConstants.typeIdSessionHiveObj)
class SessionHiveObj extends HiveObject with EquatableMixin {

  static const String keyValue = 'session';

  @HiveField(0)
  final Map<String, dynamic> values;

  SessionHiveObj({
    required this.values
  });

  @override
  List<Object?> get props => [values];
}