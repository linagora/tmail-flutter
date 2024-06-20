import 'package:collection/collection.dart';
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/login/data/extensions/account_cache_extensions.dart';
import 'package:tmail_ui_user/features/login/data/model/account_cache.dart';

extension ListAccountCacheExtension on List<AccountCache> {
  List<AccountCache> unselected() => map((account) => account.unselected()).toList();

  List<AccountCache> removeDuplicated() {
    log('ListAccountCacheExtension::removeDuplicated:BEFORE: $this');
    final listAccountId = map((account) => account.accountId).whereNotNull().toSet();
    retainWhere((account) => listAccountId.remove(account.accountId));
    log('ListAccountCacheExtension::removeDuplicated:AFTER: $this');
    return this;
  }

  Map<String, AccountCache> toMap() {
    return {
      for (var account in this)
        account.id: account
    };
  }
}