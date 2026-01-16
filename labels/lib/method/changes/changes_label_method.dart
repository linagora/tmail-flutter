import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/state_converter.dart';
import 'package:jmap_dart_client/http/converter/unsigned_int_nullable_converter.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/method/request/changes_method.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:labels/labels.dart';

part 'changes_label_method.g.dart';

@JsonSerializable(
  converters: [
    StateConverter(),
    AccountIdConverter(),
    UnsignedIntNullableConverter(),
  ],
)
class ChangesLabelMethod extends ChangesMethod {
  ChangesLabelMethod(
    super.accountId,
    super.sinceState, {
    UnsignedInt? maxChanges,
  });

  @override
  MethodName get methodName => MethodName('Label/changes');

  @override
  List<Object?> get props => [accountId, sinceState, maxChanges];

  @override
  Set<CapabilityIdentifier> get requiredCapabilities => {
        CapabilityIdentifier.jmapCore,
        LabelsConstants.labelsCapability,
      };

  factory ChangesLabelMethod.fromJson(Map<String, dynamic> json) =>
      _$ChangesLabelMethodFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChangesLabelMethodToJson(this);
}
