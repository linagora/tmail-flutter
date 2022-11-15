import 'package:fcm/model/firebase_subscription.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/state_converter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/method/response/get_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'firebase_subscription_get_response.g.dart';

@StateConverter()
@IdConverter()
@JsonSerializable(explicitToJson: true)
class FirebaseSubscriptionGetResponse extends GetResponseNoAccountId<FirebaseSubscription> {

  FirebaseSubscriptionGetResponse(
    List<FirebaseSubscription> list,
    List<Id>? notFound
  ) : super(list, notFound);

  factory FirebaseSubscriptionGetResponse.fromJson(Map<String, dynamic> json) =>
    _$FirebaseSubscriptionGetResponseFromJson(json);

  static FirebaseSubscriptionGetResponse deserialize(Map<String, dynamic> json) {
    return FirebaseSubscriptionGetResponse.fromJson(json);
  }

  Map<String, dynamic> toJson() => _$FirebaseSubscriptionGetResponseToJson(this);

  @override
  List<Object?> get props => [list, notFound];
}