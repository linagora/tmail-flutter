import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:vm_service/vm_service.dart' show AllocationProfile, VmService;
import 'package:vm_service/vm_service_io.dart';

/// Android: reads the Dart allocation profile from the app's own VM service
/// and posts it as JSON to `<sidecarUrl>/sample`.
Future<void> postSample({
  required String sidecarUrl,
  required String caseId,
  required String label,
}) async {
  final isolateId = _ownIsolateId();
  final vm = await _connectToOwnVmService();
  try {
    final profile = await vm
        .getAllocationProfile(isolateId, gc: true)
        .timeout(const Duration(seconds: 60));
    await _send(sidecarUrl, {
      'case': caseId,
      'label': label,
      'platform': 'android',
      'heapUsage': profile.memoryUsage!.heapUsage,
      'externalUsage': profile.memoryUsage!.externalUsage,
      'rss': ProcessInfo.currentRss,
      'classes': _classRows(profile),
    });
  } finally {
    await vm.dispose().timeout(const Duration(seconds: 10));
  }
}

String _ownIsolateId() {
  final isolateId = Service.getIsolateId(Isolate.current);
  if (isolateId == null) {
    throw StateError('memory measurement unavailable: no isolate id');
  }
  return isolateId;
}

Future<VmService> _connectToOwnVmService() async {
  var info = await Service.getInfo();
  if (info.serverWebSocketUri == null) {
    info = await Service.controlWebServer(enable: true);
  }
  final uri = info.serverWebSocketUri;
  if (uri == null) {
    throw StateError('memory measurement unavailable: run with --profile');
  }
  return vmServiceConnectUri(uri.toString())
      .timeout(const Duration(seconds: 30));
}

List<Map<String, Object?>> _classRows(AllocationProfile profile) => [
  for (final member in profile.members!)
    if ((member.instancesCurrent ?? 0) > 0)
      {
        'class': member.classRef!.name,
        'lib': member.classRef!.library?.uri,
        'count': member.instancesCurrent,
        'bytes': member.bytesCurrent,
      },
];

Future<void> _send(String sidecarUrl, Map<String, Object?> payload) async {
  final response = await Dio().post<String>(
    '$sidecarUrl/sample',
    data: payload,
    options: Options(
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (_) => true,
    ),
  );
  if (response.statusCode != 200) {
    throw StateError('sidecar ${response.statusCode}: ${response.data}');
  }
}
