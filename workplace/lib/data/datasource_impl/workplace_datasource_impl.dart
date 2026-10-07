import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:workplace/data/model/workplace_exchange_token_response.dart';
import '../model/workplace_exchange_token_request.dart';
import '../datasource/workplace_datasource.dart';
import '../model/workplace_enums.dart';
import '../model/workplace_intent_request.dart';
import '../model/workplace_intent_response.dart';
import '../workplace_dio.dart';
import 'workplace_drive_file_gateway.dart';
import 'workplace_request_executor.dart';
import '../../domain/entity/drive_uploaded_file.dart';
import '../../domain/entity/workplace_intent.dart';
import '../../domain/entity/workplace_access_mode.dart';
import '../../domain/entity/workplace_intent_config.dart';
import '../../domain/entity/workplace_upload_file_spec.dart';
import '../../domain/entity/workplace_upload_transfer.dart';

class WorkplaceDataSourceImpl implements WorkplaceDataSource {
  WorkplaceDataSourceImpl({WorkplaceRequestExecutor? executor})
      : _executor = executor ?? const WorkplaceRequestExecutor(),
        _driveFiles = WorkplaceDriveFileGateway(executor ?? const WorkplaceRequestExecutor());

  final WorkplaceRequestExecutor _executor;
  final WorkplaceDriveFileGateway _driveFiles;

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
    required WorkplaceAccessMode accessMode,
    required WorkplaceIntentConfig config,
  }) async {
    final data = await _executor.send(
      context: WorkplaceRequestContext(
        platformUrl: platformUrl,
        accessMode: accessMode,
      ),
      route: const WorkplaceRequestRoute(
        method: 'POST',
        pathSegments: ['intents'],
      ),
      body: WorkplaceRequestBody(data: _buildIntentRequest(config)),
    );
    return parseIntentResponse(data);
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

  @override
  Future<DriveUploadedFile> uploadFile({
    required WorkplaceRequestContext context,
    required WorkplaceUploadFileSpec spec,
    WorkplaceUploadTransfer transfer = const WorkplaceUploadTransfer(),
  }) => _driveFiles.uploadFile(context: context, spec: spec, transfer: transfer);
}
