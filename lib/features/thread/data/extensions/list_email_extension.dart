
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_cache.dart';

extension ListEmailExtension on List<Email> {
  Map<String, EmailCache> toMapCache(AccountId accountId, UserName userName) {
    return {
      for (var email in this)
        TupleKey(email.id!.asString, accountId.asString, userName.value).encodeKey : email.toEmailCache()
    };
  }

  List<Email> sortingByOrderOfIdList(List<Id> ids) {
    if (ids.length != length) {
      return this;
    }

    sort((email1, email2) {
      final id1 = email1.id?.id;
      final id2 = email2.id?.id;

      if (id1 == null || id2 == null) {
        return 0;
      }

      final index1 = ids.indexWhere((id) => id == id1);
      final index2 = ids.indexWhere((id) => id == id2);

      return index1.compareTo(index2);
    });

    return this;
  }
}