import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/set/set_method_properties_converter.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/method/request/set_method.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:labels/labels.dart';

class SetLabelMethod extends SetMethod<Label> {
  SetLabelMethod(super.accountId);

  @override
  MethodName get methodName => MethodName('Label/set');

  @override
  Set<CapabilityIdentifier> get requiredCapabilities => {
        CapabilityIdentifier.jmapCore,
        LabelsConstants.labelsCapability,
      };

  @override
  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{
      'accountId': const AccountIdConverter().toJson(accountId),
    };

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('ifInState', ifInState?.value);
    writeNotNull(
      'create',
      create?.map((id, create) =>
          SetMethodPropertiesConverter().fromMapIdToJson(id, create.toJson())),
    );
    writeNotNull(
      'update',
      update
          ?.map((id, update) => SetMethodPropertiesConverter().fromMapIdToJson(
                id,
                update.toJson(),
              )),
    );
    writeNotNull(
      'destroy',
      destroy
          ?.map((destroyId) => const IdConverter().toJson(destroyId))
          .toList(),
    );
    writeNotNull('#destroy', referenceDestroy?.toJson());

    return val;
  }

  @override
  List<Object?> get props => [accountId, ifInState, create, update, destroy];
}
