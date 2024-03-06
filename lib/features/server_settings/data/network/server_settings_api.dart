import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:server_settings/server_settings/get/get_server_settings_method.dart';
import 'package:server_settings/server_settings/get/get_server_settings_response.dart';
import 'package:server_settings/server_settings/server_settings_id.dart';
import 'package:server_settings/server_settings/set/set_server_settings_method.dart';
import 'package:server_settings/server_settings/set/set_server_settings_response.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/server_settings/domain/exceptions/server_settings_exception.dart';

class ServerSettingsAPI with HandleSetErrorMixin {
  final HttpClient httpClient;

  ServerSettingsAPI(this.httpClient);

  Future<TMailServerSettings> getServerSettings(AccountId accountId) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    final getServerSettingsMethod = GetServerSettingsMethod(accountId);

    final queryInvocation = jmapRequestBuilder.invocation(getServerSettingsMethod);

    final capabilities = getServerSettingsMethod.requiredCapabilities;

    final result = await (jmapRequestBuilder..usings(capabilities))
      .build()
      .execute();

    final serverSettings = result.parse<GetServerSettingsResponse>(
      queryInvocation.methodCallId,
      GetServerSettingsResponse.deserialize
    )?.list.firstOrNull;

    if (serverSettings == null) {
      throw NotFoundServerSettingsException();
    }

    return serverSettings;
  }

  Future<TMailServerSettings> updateServerSettings(
    AccountId accountId, 
    TMailServerSettings serverSettings
  ) async {
    final processingInvocation = ProcessingInvocation();

    final setServerSettingsMethod = SetServerSettingsMethod(accountId)
      ..addUpdatesSingleton({
        ServerSettingsIdExtension.serverSettingsIdSingleton.id: serverSettings
      });

    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);
    final setServerSettigsInvocation = jmapRequestBuilder.invocation(
      setServerSettingsMethod);

    final getServerSettingsMethod = GetServerSettingsMethod(accountId)
      ..addIds({ServerSettingsIdExtension.serverSettingsIdSingleton.id});

    final getServerSettingsInvocation = jmapRequestBuilder.invocation(
      getServerSettingsMethod);

    final capabilities = setServerSettingsMethod.requiredCapabilities;

    final result = await (jmapRequestBuilder..usings(capabilities))
      .build()
      .execute();

    try {
      final updateServerSettingsResult = result.parse<SetServerSettingsResponse>(
        setServerSettigsInvocation.methodCallId,
        SetServerSettingsResponse.deserialize
      )?.updated ?? {};

      if (updateServerSettingsResult.isEmpty) {
        throw CanNotUpdateServerSettingsException();
      }
    } on ErrorMethodResponseException catch (_) {
      throw CanNotUpdateServerSettingsException();
    }

    try {
      final updatedServerSettings = result.parse<GetServerSettingsResponse>(
        getServerSettingsInvocation.methodCallId,
        GetServerSettingsResponse.deserialize
      )?.list.firstOrNull;

      if (updatedServerSettings == null) {
        throw CanNotUpdateServerSettingsException();
      }

      return updatedServerSettings;
    } on ErrorMethodResponseException catch (_) {
      throw CanNotUpdateServerSettingsException();
    }
  }
}