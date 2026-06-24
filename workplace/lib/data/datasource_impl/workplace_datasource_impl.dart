import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../model/workplace_exchange_token_request.dart';
import '../datasource/workplace_datasource.dart';
import '../model/workplace_enums.dart';
import '../model/workplace_intent_request.dart';
import '../model/workplace_intent_response.dart';
import '../workplace_dio.dart';
import '../../domain/entity/workplace_intent.dart';

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
    required String accessToken, 
    required String addAsLink,
    required String addAsAttachment,
  }) async {
    final response = await WorkplaceDio.instance.post(
      '$platformUrl/intents',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        extra: {'withCredentials': true},
      ),
      data: _buildIntentRequest(
        addAsLink: addAsLink,
        addAsAttachment: addAsAttachment,
      ),
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

    return WorkplaceIntent(intentId: parsed.data.id, intentUrl: intentUrl);
  }

  Map<String, dynamic> _buildIntentRequest({
    required String addAsLink,
    required String addAsAttachment,
  }) => WorkplaceIntentRequest(
    data: WorkplaceIntentDataRequest(
      type: WorkplaceDataRequestType.intents,
      attributes: WorkplaceIntentAttributesRequest(
        action: WorkplaceAction.pick,
        type: WorkplaceAttributesRequestType.files,
        permissions: [WorkplacePermission.get],
        actions: [
          WorkplaceIntentActionsRequest(
            addAsLink: addAsLink,
            addAsAttachment: addAsAttachment,
          ),
        ],
      ),
    ),
  ).toJson();

  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) async {
    final response = await WorkplaceDio.instance.post(
      '$platformUrl/auth/token_exchange',
      data: WorkplaceExchangeTokenRequest(
        idToken: oidcIdToken,
        exchangeType: WorkplaceExchangeType.app,
      ).toJson(),
    );
    final data = _asJsonMap(response.data);
    final accessToken = data['access_token'];
    if (accessToken is! String) {
      throw StateError('Invalid token response: access_token is ${accessToken.runtimeType}');
    }
    return accessToken;
  }
}
