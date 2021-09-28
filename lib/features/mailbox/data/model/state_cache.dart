
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/mailbox/data/utils/caching_constants.dart';

part 'state_cache.g.dart';

@HiveType(typeId: CachingConstants.STATE_CACHE_IDENTIFY)
class StateCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final StateType type;

  @HiveField(1)
  final String state;

  StateCache(this.type, this.state);

  @override
  List<Object?> get props => [type, state];
}