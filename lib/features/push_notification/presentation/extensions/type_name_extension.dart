
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';

extension TypeNameExtension on TypeName {
  String getTupleKeyStored(AccountId accountId, UserName userName) {
    return TupleKey(value, accountId.asString, userName.value).encodeKey;
  }

  String getTupleKeyStoredWithoutAccount() {
    return TupleKey(value).encodeKey;
  }
}