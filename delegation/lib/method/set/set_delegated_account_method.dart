import 'package:delegation/model/delegated_account.dart';
import 'package:delegation/utils/delegation_constants.dart';
import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/method/request/set_method.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';

/// The server implements only `destroy`.
class SetDelegatedAccountMethod extends SetMethod<DelegatedAccount> {
  SetDelegatedAccountMethod(super.accountId);

  @override
  MethodName get methodName => MethodName('DelegatedAccount/set');

  @override
  Set<CapabilityIdentifier> get requiredCapabilities => {
        CapabilityIdentifier.jmapCore,
        DelegationConstants.delegationCapability,
      };

  @override
  List<Object?> get props => [methodName, accountId, ifInState, destroy, referenceDestroy, requiredCapabilities];

  @override
  Map<String, dynamic> toJson() => {
        'accountId': const AccountIdConverter().toJson(accountId),
        if (ifInState != null) 'ifInState': ifInState!.value,
        if (destroy != null)
          'destroy': destroy!.map(const IdConverter().toJson).toList(),
        if (referenceDestroy != null) '#destroy': referenceDestroy!.toJson(),
      };
}
