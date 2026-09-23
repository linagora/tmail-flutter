import 'package:dio/dio.dart';

import '../../domain/entity/workplace_access_mode.dart';
import '../../domain/entity/workplace_request_context.dart';
import '../../domain/entity/workplace_request_transfer.dart';
import '../bridge/cozy_bridge.dart';
import '../workplace_dio.dart';

export '../../domain/entity/workplace_request_context.dart';
export '../../domain/entity/workplace_request_transfer.dart';

/// What a Workplace request targets on the stack.
class WorkplaceRequestRoute {
  final String method;
  final List<String> pathSegments;
  final Map<String, String> queryParameters;

  const WorkplaceRequestRoute({
    required this.method,
    required this.pathSegments,
    this.queryParameters = const {},
  });
}

/// What a Workplace request carries.
class WorkplaceRequestBody {
  final Object? data;
  final Map<String, String> headers;
  final Map<String, dynamic> extra;

  const WorkplaceRequestBody({
    this.data,
    this.headers = const {},
    this.extra = const {},
  });
}

/// Sends one cozy-stack request over whichever access mode was resolved.
class WorkplaceRequestExecutor {
  const WorkplaceRequestExecutor();

  Future<dynamic> send({
    required WorkplaceRequestContext context,
    required WorkplaceRequestRoute route,
    WorkplaceRequestBody body = const WorkplaceRequestBody(),
    WorkplaceRequestTransfer transfer = const WorkplaceRequestTransfer(),
  }) async {
    return switch (context.accessMode) {
      // The bridge resolves once: no extra, no progress, no cancellation.
      BridgeAccessMode() => CozyBridge.fetchJson(
          method: route.method,
          path: _bridgePath(route),
          body: body.data,
          headers: body.headers.isEmpty ? null : body.headers,
        ),
      BearerTokenAccessMode(:final accessToken) => _sendWithBearerToken(
          context.platformUrl, accessToken, route, body, transfer),
    };
  }

  String _bridgePath(WorkplaceRequestRoute route) {
    // Encode each segment so a literal '/' (e.g. a magic-folder id) becomes %2F.
    final path = '/${route.pathSegments.map(Uri.encodeComponent).join('/')}';
    if (route.queryParameters.isEmpty) return path;
    final query = route.queryParameters.entries
        .map((entry) =>
            '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}')
        .join('&');
    return '$path?$query';
  }

  Future<dynamic> _sendWithBearerToken(
    Uri platformUrl,
    String accessToken,
    WorkplaceRequestRoute route,
    WorkplaceRequestBody body,
    WorkplaceRequestTransfer transfer,
  ) async {
    // Fail fast instead of sending a malformed Authorization header.
    if (accessToken.trim().isEmpty) {
      throw StateError('Access token is empty');
    }
    final url = platformUrl.replace(
      pathSegments: [
        ...platformUrl.pathSegments.where((segment) => segment.isNotEmpty),
        ...route.pathSegments,
      ],
      queryParameters: {
        ...platformUrl.queryParameters,
        ...route.queryParameters,
        // Required for cozy-stack to accept a bearer-only (no session) request.
        'force_session_id': 'true',
      },
    ).toString();
    final response = await WorkplaceDio.instance.request(
      url,
      options: Options(
        method: route.method,
        headers: {'Authorization': 'Bearer $accessToken', ...body.headers},
        extra: body.extra,
        sendTimeout: transfer.timeout,
        receiveTimeout: transfer.timeout,
      ),
      data: body.data,
      onSendProgress: transfer.onSendProgress,
      cancelToken: transfer.cancelToken,
    );
    return response.data;
  }
}
