import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:server_settings/server_settings/server_settings_id.dart';

class ServerSettingsIdNullableConverter implements JsonConverter<ServerSettingsId?, String?> {
  const ServerSettingsIdNullableConverter();

  @override
  ServerSettingsId? fromJson(String? json) => json != null ? ServerSettingsId(id: Id(json)) : null;

  @override
  String? toJson(ServerSettingsId? object) => object?.id.value;
}
