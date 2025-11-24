import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/state_nullable_converter.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/method/response/set_response.dart';
import 'package:labels/model/label.dart';

class SetLabelResponse extends SetResponse<Label> {
  SetLabelResponse(
    super.accountId, {
    super.newState,
    super.oldState,
    super.created,
    super.updated,
    super.destroyed,
    super.notCreated,
    super.notUpdated,
    super.notDestroyed,
  });

  static SetLabelResponse deserialize(Map<String, dynamic> json) {
    return SetLabelResponse(
      const AccountIdConverter().fromJson(json['accountId'] as String),
      newState:
          const StateNullableConverter().fromJson(json['newState'] as String?),
      oldState:
          const StateNullableConverter().fromJson(json['oldState'] as String?),
      created: (json['created'] as Map<String, dynamic>?)?.map((key, value) =>
          MapEntry(const IdConverter().fromJson(key),
              Label.fromJson(value as Map<String, dynamic>))),
      updated: (json['updated'] as Map<String, dynamic>?)?.map((key, value) =>
          MapEntry(
              const IdConverter().fromJson(key),
              value != null
                  ? Label.fromJson(value as Map<String, dynamic>)
                  : null)),
      destroyed: (json['destroyed'] as List<dynamic>?)
          ?.map((id) => const IdConverter().fromJson(id))
          .toSet(),
      notCreated: (json['notCreated'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(
              const IdConverter().fromJson(key), SetError.fromJson(value))),
      notUpdated: (json['notUpdated'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(
              const IdConverter().fromJson(key), SetError.fromJson(value))),
      notDestroyed: (json['notDestroyed'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(
              const IdConverter().fromJson(key), SetError.fromJson(value))),
    );
  }

  @override
  List<Object?> get props => [
        oldState,
        newState,
        created,
        updated,
        destroyed,
        notCreated,
        notUpdated,
        notDestroyed
      ];
}
