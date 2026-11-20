import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/state_nullable_converter.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/method/response/set_response.dart';

class SetDelegateResponse extends SetResponse<Id> {
  SetDelegateResponse(
    super.accountId, {
    super.newState,
    super.oldState,
    super.created,
    super.notCreated,
    super.destroyed,
    super.notDestroyed,
  });

  static SetDelegateResponse deserialize(Map<String, dynamic> json) {
    return SetDelegateResponse(
      const AccountIdConverter().fromJson(json['accountId'] as String),
      newState: const StateNullableConverter().fromJson(json['newState'] as String?),
      oldState: const StateNullableConverter().fromJson(json['oldState'] as String?),
      created: (json['created'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          const IdConverter().fromJson(key),
          const IdConverter().fromJson((value as Map<String, dynamic>)['id'] as String),
        ),
      ),
      notCreated: (json['notCreated'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(const IdConverter().fromJson(key), SetError.fromJson(value)),
      ),
      destroyed: (json['destroyed'] as List<dynamic>?)
          ?.map((id) => const IdConverter().fromJson(id as String))
          .toSet(),
      notDestroyed: (json['notDestroyed'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(const IdConverter().fromJson(key), SetError.fromJson(value)),
      ),
    );
  }

  @override
  List<Object?> get props =>
      [accountId, oldState, newState, created, notCreated, destroyed, notDestroyed];
}
