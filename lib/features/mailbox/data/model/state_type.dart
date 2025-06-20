
import 'package:hive_ce/hive.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'state_type.g.dart';

@HiveType(typeId: CachingConstants.STATE_TYPE_IDENTIFY)
enum StateType {

  @HiveField(0)
  mailbox,

  @HiveField(1)
  email;

  String getTupleKeyStored(AccountId accountId, UserName userName) {
    return TupleKey(name, accountId.asString, userName.value).encodeKey;
  }

  String getTupleKeyStoredWithoutAccount() {
    return TupleKey(name).encodeKey;
  }
}