import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dio/dio.dart';

/// Web: tags this page with [caseId] so the sidecar can find it over CDP,
/// then asks the sidecar to take a heap snapshot (`<sidecarUrl>/snapshot`).
Future<void> postSample({
  required String sidecarUrl,
  required String caseId,
  required String label,
}) async {
  globalContext['__tmailMemoryProbeId'] = caseId.toJS;
  final response = await Dio().post<String>(
    '$sidecarUrl/snapshot',
    queryParameters: {'case': caseId, 'label': label},
    options: Options(
      receiveTimeout: const Duration(seconds: 120),
      validateStatus: (_) => true,
    ),
  );
  if (response.statusCode != 200) {
    throw StateError('sidecar ${response.statusCode}: ${response.data}');
  }
}
