import 'package:delegation/model/delegated_account.dart';
import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/state_nullable_converter.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/method/response/set_response.dart';

class SetDelegatedAccountResponse extends SetResponse<DelegatedAccount> {
  SetDelegatedAccountResponse(
    super.accountId, {
    super.newState,
    super.oldState,
    super.destroyed,
    super.notDestroyed,
  });

  static SetDelegatedAccountResponse deserialize(Map<String, dynamic> json) {
    return SetDelegatedAccountResponse(
      const AccountIdConverter().fromJson(json['accountId'] as String),
      newState: const StateNullableConverter().fromJson(json['newState'] as String?),
      oldState: const StateNullableConverter().fromJson(json['oldState'] as String?),
      destroyed: (json['destroyed'] as List<dynamic>?)
          ?.map((id) => const IdConverter().fromJson(id as String))
          .toSet(),
      notDestroyed: (json['notDestroyed'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(const IdConverter().fromJson(key), SetError.fromJson(value))),
    );
  }

  @override
  List<Object?> get props => [accountId, oldState, newState, destroyed, notDestroyed];
}
