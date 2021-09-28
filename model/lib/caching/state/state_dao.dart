
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:model/model.dart';

part 'state_dao.g.dart';

@HiveType(typeId: CachingConstants.STATE_DAO_IDENTIFY)
class StateDao extends HiveObject with EquatableMixin {

  @HiveField(0)
  final StateType type;

  @HiveField(1)
  final String state;

  StateDao(this.type, this.state);

  @override
  List<Object?> get props => [type, state];
}