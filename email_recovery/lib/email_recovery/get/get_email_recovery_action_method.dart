import 'package:email_recovery/email_recovery/capability_deleted_messages_vault.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/method/request/get_method.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/http/converter/properties_converter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:jmap_dart_client/jmap/core/request/result_reference.dart';

part 'get_email_recovery_action_method.g.dart';

@IdConverter()
@PropertiesConverter()
@JsonSerializable(explicitToJson: true)
class GetEmailRecoveryActionMethod extends GetMethodNoNeedAccountId {
  GetEmailRecoveryActionMethod() : super();
  
  @override
  MethodName get methodName => MethodName('EmailRecoveryAction/get');

  @override
  Set<CapabilityIdentifier> get requiredCapabilities => {
    CapabilityIdentifier.jmapCore,
    capabilityDeletedMessagesVault
  };

  @override
  List<Object?> get props => [methodName, ids, properties, requiredCapabilities];

  factory GetEmailRecoveryActionMethod.fromJson(Map<String, dynamic> json) => _$GetEmailRecoveryActionMethodFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetEmailRecoveryActionMethodToJson(this);
}