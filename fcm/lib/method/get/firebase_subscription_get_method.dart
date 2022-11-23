import 'package:fcm/model/firebase_capability.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/properties_converter.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/method/request/get_method.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/request/result_reference.dart';
import 'package:json_annotation/json_annotation.dart';

part 'firebase_subscription_get_method.g.dart';

@IdConverter()
@PropertiesConverter()
@JsonSerializable(explicitToJson: true)
class FirebaseSubscriptionGetMethod extends GetMethodNoNeedAccountId {

  FirebaseSubscriptionGetMethod() : super();

  @override
  MethodName get methodName => MethodName('FirebaseRegistration/get');

  @override
  Set<CapabilityIdentifier> get requiredCapabilities => {
    CapabilityIdentifier.jmapCore,
    FirebaseCapability.fcmIdentifier,
  };

  @override
  List<Object?> get props => [methodName, ids, requiredCapabilities];

  factory FirebaseSubscriptionGetMethod.fromJson(Map<String, dynamic> json) => _$FirebaseSubscriptionGetMethodFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FirebaseSubscriptionGetMethodToJson(this);
}