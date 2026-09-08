import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../model/workplace_enums.dart';
import '../model/workplace_intent_request.dart';
import '../model/workplace_intent_response.dart';
import '../../domain/entity/workplace_intent.dart';
import '../../domain/entity/workplace_intent_config.dart';

// Shared by every route to Drive, so bridge and HTTP send and read the same shape.

Map<String, dynamic> asJsonMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is String) return jsonDecode(data) as Map<String, dynamic>;
  throw FormatException(
    'Expected JSON object or string, got: ${data.runtimeType}',
  );
}

Map<String, dynamic> buildIntentRequestBody(WorkplaceIntentConfig config) =>
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

WorkplaceIntent parseIntentResponse(
  dynamic data, {
  bool requireHttps = kReleaseMode,
}) {
  final parsed = WorkplaceIntentResponse.fromJson(asJsonMap(data));
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
