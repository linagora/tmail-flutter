import 'package:delegation/utils/delegation_constants.dart';
import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/properties_converter.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/method/request/get_method.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/request/result_reference.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_delegated_account_method.g.dart';

@JsonSerializable(
  explicitToJson: true,
  converters: [
    IdConverter(),
    AccountIdConverter(),
    PropertiesConverter(),
  ],
)
class GetDelegatedAccountMethod extends GetMethod {
  GetDelegatedAccountMethod(super.accountId);

  @override
  MethodName get methodName => MethodName('DelegatedAccount/get');

  @override
  Set<CapabilityIdentifier> get requiredCapabilities => {
        CapabilityIdentifier.jmapCore,
        DelegationConstants.delegationCapability,
      };

  @override
  List<Object?> get props => [methodName, accountId, ids, requiredCapabilities];

  factory GetDelegatedAccountMethod.fromJson(Map<String, dynamic> json) =>
      _$GetDelegatedAccountMethodFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetDelegatedAccountMethodToJson(this);
}
