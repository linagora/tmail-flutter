import 'dart:convert';

import 'package:dio/dio.dart';
import '../model/workplace_exchange_token_request.dart';
import '../datasource/workplace_datasource.dart';
import '../model/workplace_enums.dart';
import '../model/workplace_intent_request.dart';
import '../model/workplace_intent_response.dart';
import '../../domain/entity/workplace_intent.dart';

class WorkplaceDataSourceImpl implements WorkplaceDataSource {
  final Dio _dio;

  WorkplaceDataSourceImpl(this._dio);

  @override
  Future<WorkplaceIntent> createIntent(Uri platformUrl, String accessToken) async {
    final response = await _dio.post(
      '$platformUrl/intents',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
      data: const WorkplaceIntentRequest(
        data: WorkplaceIntentDataRequest(
          type: WorkplaceDataRequestType.intents,
          attributes: WorkplaceIntentAttributesRequest(
            action: WorkplaceAction.pick,
            type: WorkplaceAttributesRequestType.files,
            permissions: [WorkplacePermission.get],
          ),
        ),
      ).toJson(),
    );
    final parsed = WorkplaceIntentResponse.fromJson(
      response.data is Map<String, dynamic>
          ? response.data
          : jsonDecode(response.data),
    );
    final intentId = parsed.data.id;
    final services = parsed.data.attributes.services;
    if (services.isEmpty) {
      throw StateError('Drive response contains no services');
    }
    final href = parsed.data.attributes.services.first.href;
    final intentUrl = Uri.parse(href);
    if (intentUrl.scheme != 'https') {
      throw ArgumentError('Intent URL must use HTTPS, got: $href');
    }
    return WorkplaceIntent(intentId: intentId, intentUrl: intentUrl);
  }

  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) async {
    final response = await _dio.post(
      '$platformUrl/auth/token_exchange',
      data: WorkplaceExchangeTokenRequest(idToken: oidcIdToken).toJson(),
    );
    final accessToken = response.data['access_token'];
    if (accessToken is! String) {
      throw StateError('Invalid token response: access_token is ${accessToken.runtimeType}');
    }
    return accessToken;
  }
}
