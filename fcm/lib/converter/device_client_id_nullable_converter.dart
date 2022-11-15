import 'package:fcm/model/device_client_id.dart';
import 'package:json_annotation/json_annotation.dart';

class DeviceClientIdNullableConverter implements JsonConverter<DeviceClientId?, String?> {
  const DeviceClientIdNullableConverter();

  @override
  DeviceClientId? fromJson(String? json) => json != null ? DeviceClientId(json) : null;

  @override
  String? toJson(DeviceClientId? object) => object?.value;
}
