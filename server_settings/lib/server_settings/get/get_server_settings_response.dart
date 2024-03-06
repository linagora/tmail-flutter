
import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/state_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/method/response/get_response.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';

part 'get_server_settings_response.g.dart';

@JsonSerializable(converters: [
  StateConverter(),
  AccountIdConverter(),
  IdConverter()
])
class GetServerSettingsResponse extends GetResponse<TMailServerSettings> {
  GetServerSettingsResponse(AccountId accountId, State state, List<TMailServerSettings> list, List<Id>? notFound) : super(accountId, state, list, notFound);

  factory GetServerSettingsResponse.fromJson(Map<String, dynamic> json) => 
    _$GetServerSettingsResponseFromJson(json);

  static GetServerSettingsResponse deserialize(Map<String, dynamic> json) {
    return GetServerSettingsResponse.fromJson(json);
  }

  Map<String, dynamic> toJson() => _$GetServerSettingsResponseToJson(this);

  @override
  List<Object?> get props => [accountId, state, list, notFound];
}