import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/properties_converter.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/method/request/get_method.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/request/result_reference.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:labels/labels.dart';

part 'get_label_method.g.dart';

@JsonSerializable(
  explicitToJson: true,
  converters: [
    IdConverter(),
    AccountIdConverter(),
    PropertiesConverter(),
  ],
)
class GetLabelMethod extends GetMethod {
  GetLabelMethod(super.accountId);

  @override
  MethodName get methodName => MethodName('Label/get');

  @override
  Set<CapabilityIdentifier> get requiredCapabilities => {
        CapabilityIdentifier.jmapCore,
        LabelsConstants.labelsCapability,
      };

  @override
  List<Object?> get props => [methodName, accountId, ids, requiredCapabilities];

  factory GetLabelMethod.fromJson(Map<String, dynamic> json) =>
      _$GetLabelMethodFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetLabelMethodToJson(this);
}
