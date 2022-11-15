import 'package:fcm/utils/firebase_utils.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/properties_converter.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/method/request/get_method.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/request/result_reference.dart';
import 'package:json_annotation/json_annotation.dart';

part 'firebase_registration_get_method.g.dart';

@IdConverter()
@PropertiesConverter()
@JsonSerializable(explicitToJson: true)
class FirebaseRegistrationGetMethod extends GetMethodNoNeedAccountId {

  FirebaseRegistrationGetMethod() : super();

  @override
  MethodName get methodName => MethodName('FirebaseRegistration/get');

  @override
  Set<CapabilityIdentifier> get requiredCapabilities => {
    CapabilityIdentifier.jmapCore,
    FirebaseUtils.capabilityLinagoraFirebase,
  };

  @override
  List<Object?> get props => [methodName, ids, requiredCapabilities];

  factory FirebaseRegistrationGetMethod.fromJson(Map<String, dynamic> json) => _$FirebaseRegistrationGetMethodFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FirebaseRegistrationGetMethodToJson(this);
}