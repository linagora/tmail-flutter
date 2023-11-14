import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_account_extension.dart';

class SessionAccountConverter {

  MapEntry<String, dynamic> convertToMapEntry(AccountId accountId, Account account) {
    return MapEntry(
      const AccountIdConverter().toJson(accountId),
      account.toJson()
    );
  }
}