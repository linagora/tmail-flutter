
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

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