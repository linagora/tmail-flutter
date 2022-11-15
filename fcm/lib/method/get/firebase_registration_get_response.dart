import 'package:fcm/model/firebase_registration.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/state_converter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/method/response/get_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'firebase_registration_get_response.g.dart';

@StateConverter()
@IdConverter()
@JsonSerializable(explicitToJson: true)
class FirebaseRegistrationGetResponse extends GetResponseNoAccountId<FirebaseRegistration> {

  FirebaseRegistrationGetResponse(
    List<FirebaseRegistration> list,
    List<Id>? notFound
  ) : super(list, notFound);

  factory FirebaseRegistrationGetResponse.fromJson(Map<String, dynamic> json) =>
    _$FirebaseRegistrationGetResponseFromJson(json);

  static FirebaseRegistrationGetResponse deserialize(Map<String, dynamic> json) {
    return FirebaseRegistrationGetResponse.fromJson(json);
  }

  Map<String, dynamic> toJson() => _$FirebaseRegistrationGetResponseToJson(this);

  @override
  List<Object?> get props => [list, notFound];
}