
import 'package:hive/hive.dart';
import 'package:model/model.dart';

part 'state_type.g.dart';

@HiveType(typeId: CachingConstants.STATE_TYPE_IDENTIFY)
enum StateType {

  @HiveField(0)
  mailbox
}

extension StateTypeExtension on StateType {
  String get value {
    switch(this) {
      case StateType.mailbox:
        return 'mailbox';
    }
  }
}