
import 'package:fcm/method/set/firebase_subscription_set_method.dart';
import 'package:fcm/method/set/firebase_subscription_set_response.dart';
import 'package:fcm/method/get/firebase_subscription_get_method.dart';
import 'package:fcm/method/get/firebase_subscription_get_response.dart';
import 'package:fcm/model/firebase_subscription.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';

class FcmApi {

  final HttpClient _httpClient;

  FcmApi(this._httpClient);

  Future<FirebaseSubscription> getFirebaseSubscriptionByDeviceId(String deviceId) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

    final firebaseSubscriptionGetMethod = FirebaseSubscriptionGetMethod();
    final firebaseSubscriptionGetInvocation = requestBuilder.invocation(firebaseSubscriptionGetMethod);
    final response = await (requestBuilder
        ..usings(firebaseSubscriptionGetMethod.requiredCapabilities))
      .build()
      .execute();

    final getResponse = response.parse<FirebaseSubscriptionGetResponse>(
      firebaseSubscriptionGetInvocation.methodCallId,
      FirebaseSubscriptionGetResponse.deserialize);

    final matchedFirebaseSubscription = getResponse?.list
      .where((fcmSub) => fcmSub.deviceClientId?.value == deviceId)
      .toList();

    if (matchedFirebaseSubscription?.isNotEmpty == true) {
      return matchedFirebaseSubscription!.first;
    } else {
      throw NotFoundFirebaseSubscriptionException();
    }
  }

  Future<FirebaseSubscription> registerNewToken(RegisterNewTokenRequest newTokenRequest) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

    final firebaseSubscriptionSetMethod = FirebaseSubscriptionSetMethod()
      ..addCreate(
        newTokenRequest.createRequestId,
        newTokenRequest.firebaseSubscription
      );
    final firebaseSubscriptionSetInvocation = requestBuilder.invocation(firebaseSubscriptionSetMethod);
    final response = await (requestBuilder
        ..usings(firebaseSubscriptionSetMethod.requiredCapabilities))
      .build()
      .execute();

    final firebaseSubscriptionSetResponse = response.parse<FirebaseSubscriptionSetResponse>(
      firebaseSubscriptionSetInvocation.methodCallId,
      FirebaseSubscriptionSetResponse.deserialize);

    return firebaseSubscriptionSetResponse!.created![newTokenRequest.createRequestId]!;
  }
}