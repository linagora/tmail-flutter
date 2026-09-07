import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:workplace/data/model/workplace_exchange_token_response.dart';
import '../model/workplace_exchange_token_request.dart';
import '../datasource/workplace_datasource.dart';
import '../model/workplace_enums.dart';
import '../model/workplace_intent_request.dart';
import '../model/workplace_intent_response.dart';
import '../bridge/cozy_bridge.dart';
import '../workplace_dio.dart';
import '../../domain/entity/workplace_intent.dart';
import '../../domain/entity/workplace_intent_access_mode.dart';
import '../../domain/entity/workplace_intent_config.dart';

class WorkplaceDataSourceImpl implements WorkplaceDataSource {
  WorkplaceDataSourceImpl();

  Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    throw FormatException(
      'Expected JSON object or string, got: ${data.runtimeType}',
    );
  }

  @override
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required WorkplaceIntentAccessMode accessMode,
    required WorkplaceIntentConfig config,
  }) async {
    final body = _buildIntentRequest(config);

    return switch (accessMode) {
      BridgeAccessMode() => _createIntentViaBridge(body),
      BearerTokenAccessMode(:final accessToken) =>
        _createIntentViaBearerToken(platformUrl, accessToken, body),
    };
  }

  // No token: the container app already holds the stack session.
  Future<WorkplaceIntent> _createIntentViaBridge(
    Map<String, dynamic> body,
  ) async {
    final data = await CozyBridge.fetchJson(
      method: 'POST',
      path: '/intents',
      body: body,
    );
    return parseIntentResponse(data);
  }

  Future<WorkplaceIntent> _createIntentViaBearerToken(
    Uri platformUrl,
    String accessToken,
    Map<String, dynamic> body,
  ) async {
    // Fail fast instead of sending a malformed Authorization header.
    if (accessToken.trim().isEmpty) {
      throw StateError('Access token is empty');
    }
    final response = await WorkplaceDio.instance.post(
      platformUrl.replace(
        pathSegments: [
          ...platformUrl.pathSegments.where((segment) => segment.isNotEmpty),
          'intents',
        ],
        queryParameters: {
          ...platformUrl.queryParameters,
          'force_session_id': 'true',
        },
      ).toString(),
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
      data: body,
    );
    return parseIntentResponse(response.data);
  }

  WorkplaceIntent parseIntentResponse(
    dynamic data, {
    bool requireHttps = kReleaseMode,
  }) {
    final parsed = WorkplaceIntentResponse.fromJson(_asJsonMap(data));
    final services = parsed.data.attributes.services;
    if (services.isEmpty) {
      throw StateError('Drive response contains no services');
    }

    final href = services.first.href;
    final intentUrl = Uri.parse(href);
    if (requireHttps && intentUrl.scheme != 'https') {
      throw ArgumentError('Intent URL must use HTTPS, got: $href');
    }

    return WorkplaceIntent(
      intentId: parsed.data.id,
      intentUrl: intentUrl,
      client: parsed.data.attributes.client,
    );
  }

  Map<String, dynamic> _buildIntentRequest(WorkplaceIntentConfig config) =>
      WorkplaceIntentRequest(
    data: WorkplaceIntentDataRequest(
      type: WorkplaceDataRequestType.intents,
      attributes: WorkplaceIntentAttributesRequest(
        action: WorkplaceAction.pick,
        type: WorkplaceDocType.files,
        permissions: [WorkplacePermission.get],
        data: WorkplaceFilePickerConfigRequest(
          sharingLink: WorkplaceActionConfigRequest.fromEntity(config.addAsLink),
          downloadLink: config.addAsAttachment == null
              ? null
              : WorkplaceActionConfigRequest.fromEntity(config.addAsAttachment!),
          theme: WorkplaceThemeConfigRequest.fromEntity(config.theme),
        ),
      ),
    ),
  ).toJson();

  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) async {
    final response = await WorkplaceDio.instance.post(
      platformUrl.replace(
        pathSegments: [
          ...platformUrl.pathSegments.where((segment) => segment.isNotEmpty),
          'auth',
          'token_exchange',
        ],
      ).toString(),
      options: Options(
        headers: {'Accept': 'application/json'},
      ),
      data: WorkplaceExchangeTokenRequest(
        idToken: oidcIdToken,
        exchangeType: WorkplaceExchangeType.app,
      ).toJson(),
    );
    final data = WorkplaceExchangeTokenResponse.fromJson(_asJsonMap(response.data));
    final accessToken = data.accessToken;
    return accessToken;
  }
}
