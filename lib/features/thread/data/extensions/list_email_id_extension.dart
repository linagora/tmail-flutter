
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';

extension ListEmailIdExtension on List<EmailId> {
  List<String> toCacheKeyList(AccountId accountId, UserName userName) =>
    map((id) => TupleKey(id.asString, accountId.asString, userName.value).encodeKey).toList();

  List<String> get asListString => map((id) => id.asString).toList();
}