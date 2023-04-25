
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_cache.dart';

extension ListEmailExtension on List<Email> {
  Map<String, EmailCache> toMapCache(AccountId accountId) {
    return {
      for (var email in this)
        TupleKey(email.id!.asString, accountId.asString).toString() : email.toEmailCache()
    };
  }
}