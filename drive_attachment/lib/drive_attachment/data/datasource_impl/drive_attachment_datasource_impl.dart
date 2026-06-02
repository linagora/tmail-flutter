import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:drive_attachment/drive_attachment/data/datasource/drive_attachment_datasource.dart';
import 'package:drive_attachment/drive_attachment/data/model/drive_intent_response.dart';
import 'package:drive_attachment/drive_attachment/domain/entity/drive_intent.dart';

class DriveAttachmentDataSourceImpl implements DriveAttachmentDataSource {
  final Dio _dio;

  DriveAttachmentDataSourceImpl(this._dio);

  @override
  Future<DriveIntent> createIntent(Uri platformUrl, String accessToken) async {
    final response = await _dio.post(
      '$platformUrl/intents',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        extra: {'withCredentials': true},
      ),
      data: {
        'data': {
          'type': 'io.cozy.intents',
          'attributes': {
            'action': 'PICK',
            'type': 'io.cozy.files',
            'permissions': ['GET'],
          },
        },
      },
    );
    final parsed = DriveIntentResponse.fromJson(response.data as Map<String, dynamic>);
    final intentId = parsed.data.id;
    final href = parsed.data.attributes.services.first.href;
    final intentUrl = Uri.parse(href);
    if (intentUrl.scheme != 'https' && !kDebugMode) {
      throw ArgumentError('Intent URL must use HTTPS, got: $href');
    }
    return DriveIntent(intentId: intentId, intentUrl: intentUrl);
  }

  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) async {
    final response = await _dio.post(
      '$platformUrl/auth/token_exchange',
      data: {'id_token': oidcIdToken},
    );
    return response.data['access_token'] as String;
  }
}
