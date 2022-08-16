import 'package:forward/forward/capability_forward.dart';
import 'package:forward/forward/converter/rule_filter_id_coverter.dart';
import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/properties_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/method/request/get_method.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/request/result_reference.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_forward_method.g.dart';

@IdConverter()
@ForwardIdConverter()
@AccountIdConverter()
@PropertiesConverter()
@JsonSerializable(explicitToJson: true)
class GetForwardMethod extends GetMethod {
  GetForwardMethod(AccountId accountId) : super(accountId);

  @override
  MethodName get methodName => MethodName('Forward/get');

  @override
  Set<CapabilityIdentifier> get requiredCapabilities => {
    CapabilityIdentifier.jmapCore,
    capabilityForward,
  };

  @override
  List<Object?> get props => [methodName, accountId, ids, requiredCapabilities];

  factory GetForwardMethod.fromJson(Map<String, dynamic> json) => _$GetForwardMethodFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetForwardMethodToJson(this);
}