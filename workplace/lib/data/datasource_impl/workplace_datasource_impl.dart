import 'package:dio/dio.dart';
import 'package:workplace/data/model/workplace_exchange_token_response.dart';
import '../model/workplace_exchange_token_request.dart';
import '../datasource/workplace_datasource.dart';
import '../mapper/workplace_intent_mapper.dart';
import '../model/workplace_enums.dart';
import '../workplace_dio.dart';
import '../../domain/entity/workplace_intent.dart';
import '../../domain/entity/workplace_intent_config.dart';

/// Token route: direct HTTP to Drive, authenticated with an exchanged bearer token.
class WorkplaceDataSourceImpl implements WorkplaceDataSource {
  WorkplaceDataSourceImpl();

  @override
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required String accessToken,
    required WorkplaceIntentConfig config,
  }) async {
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
      data: buildIntentRequestBody(config),
    );
    return parseIntentResponse(response.data);
  }

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
    final data = WorkplaceExchangeTokenResponse.fromJson(asJsonMap(response.data));
    final accessToken = data.accessToken;
    return accessToken;
  }
}
