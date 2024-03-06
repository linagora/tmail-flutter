import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/set/set_method_properties_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/method/request/set_method.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:server_settings/server_settings/capability_server_settings.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';

class SetServerSettingsMethod extends SetMethod<TMailServerSettings> with OptionalUpdateSingleton<TMailServerSettings>{
  SetServerSettingsMethod(AccountId accountId) : super(accountId);

  @override
  MethodName get methodName => MethodName('Settings/set');

  @override
  Set<CapabilityIdentifier> get requiredCapabilities => {
    CapabilityIdentifier.jmapCore,
    capabilityServerSettings,
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
    writeNotNull('update', updateSingleton
        ?.map((id, update) => SetMethodPropertiesConverter().fromMapIdToJson(id, update.toJson())));

    return val;
  }

  @override
  List<Object?> get props => [accountId, ifInState, update];
}