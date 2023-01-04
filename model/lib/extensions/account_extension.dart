
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/account/account.dart';

extension AccountExtension on Account {

  Account fromAccountId({required AccountId accountId, required String apiUrl}) {
    return Account(
      id,
      authenticationType,
      isSelected: isSelected,
      accountId: accountId,
      apiUrl: apiUrl
    );
  }
}