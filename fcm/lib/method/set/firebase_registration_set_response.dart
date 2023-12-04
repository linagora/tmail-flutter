import 'package:fcm/model/firebase_registration.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/method/response/set_response.dart';

class FirebaseRegistrationSetResponse extends SetResponseNoAccount<FirebaseRegistration> {
  FirebaseRegistrationSetResponse({
    Map<Id, FirebaseRegistration>? created,
    Map<Id, FirebaseRegistration?>? updated,
    Set<Id>? destroyed,
    Map<Id, SetError>? notCreated,
    Map<Id, SetError>? notUpdated,
    Map<Id, SetError>? notDestroyed
  }) : super(
    created: created,
    updated: updated,
    destroyed: destroyed,
    notCreated: notCreated,
    notUpdated: notUpdated,
    notDestroyed: notDestroyed
  );

  static FirebaseRegistrationSetResponse deserialize(Map<String, dynamic> json) {
    return FirebaseRegistrationSetResponse(
      created: (json['created'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(
        const IdConverter().fromJson(key),
        FirebaseRegistration.fromJson(value as Map<String, dynamic>)
      )),
      updated: (json['updated'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(
        const IdConverter().fromJson(key),
        value != null ? FirebaseRegistration.fromJson(value as Map<String, dynamic>) : null
      )),
      destroyed: (json['destroyed'] as List<dynamic>?)?.map((id) => const IdConverter().fromJson(id)).toSet(),
      notCreated: (json['notCreated'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(
        const IdConverter().fromJson(key),
        SetError.fromJson(value)
      )),
      notUpdated: (json['notUpdated'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(
        const IdConverter().fromJson(key),
        SetError.fromJson(value)
      )),
      notDestroyed: (json['notDestroyed'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(
        const IdConverter().fromJson(key),
        SetError.fromJson(value)
      )),
    );
  }

  @override
  List<Object?> get props => [
    created,
    updated,
    destroyed,
    notCreated,
    notUpdated,
    notDestroyed
  ];
}