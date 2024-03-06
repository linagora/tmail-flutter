import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/properties_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/method/request/get_method.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/request/result_reference.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:server_settings/server_settings/capability_server_settings.dart';

part 'get_server_settings_method.g.dart';

@JsonSerializable(
  explicitToJson: true,
  converters: [
    IdConverter(),
    AccountIdConverter(),
    PropertiesConverter()
  ])
class GetServerSettingsMethod extends GetMethod {
  GetServerSettingsMethod(AccountId accountId) : super(accountId);

  @override
  MethodName get methodName => MethodName('Settings/get');

  @override
  Set<CapabilityIdentifier> get requiredCapabilities => {
    CapabilityIdentifier.jmapCore,
    capabilityServerSettings,
  };

  @override
  List<Object?> get props => [methodName, accountId, ids, requiredCapabilities];

  factory GetServerSettingsMethod.fromJson(Map<String, dynamic> json) => _$GetServerSettingsMethodFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetServerSettingsMethodToJson(this);
}