import 'package:delegation/model/delegate_creation.dart';
import 'package:delegation/utils/delegation_constants.dart';
import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/method/request/set_method.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';

/// The server implements only create and destroy.
class SetDelegateMethod extends SetMethod<DelegateCreation> {
  SetDelegateMethod(super.accountId);

  @override
  MethodName get methodName => MethodName('Delegate/set');

  @override
  Set<CapabilityIdentifier> get requiredCapabilities => {
        CapabilityIdentifier.jmapCore,
        DelegationConstants.delegationCapability,
      };

  @override
  List<Object?> get props =>
      [methodName, accountId, ifInState, create, destroy, referenceDestroy, requiredCapabilities];

  @override
  Map<String, dynamic> toJson() => {
        'accountId': const AccountIdConverter().toJson(accountId),
        if (ifInState != null) 'ifInState': ifInState!.value,
        if (create != null)
          'create': create!.map(
            (id, creation) => MapEntry(const IdConverter().toJson(id), creation.toJson()),
          ),
        if (destroy != null)
          'destroy': destroy!.map(const IdConverter().toJson).toList(),
        if (referenceDestroy != null) '#destroy': referenceDestroy!.toJson(),
      };
}
