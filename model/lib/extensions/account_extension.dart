
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:model/account/jmap_account.dart';

extension AccountExtension on Account {
  JmapAccount toJmapAccount(AccountId accountId) {
    return JmapAccount(
      accountId,
      name,
      isPersonal,
      isReadOnly,
      accountCapabilities);
  }
}