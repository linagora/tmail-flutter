import 'package:flutter/painting.dart';
import 'package:patrol/patrol.dart';

import 'memory_probe_io.dart'
    if (dart.library.js_interop) 'memory_probe_web.dart' as platform;

const String _sidecarUrl = String.fromEnvironment('MEMORY_SIDECAR_URL');

/// Settles the app, then sends one memory sample to the CI sidecar.
///
/// Fails fast when the sidecar is not configured or the platform cannot
/// measure, so a leak check never passes silently.
Future<void> sampleMemory(
  PatrolIntegrationTester $, {
  required String caseId,
  required String label,
}) async {
  if (_sidecarUrl.isEmpty) {
    throw StateError('MEMORY_SIDECAR_URL is not set');
  }
  // imageCache is a bounded framework cache, not a leak.
  PaintingBinding.instance.imageCache
    ..clear()
    ..clearLiveImages();
  await $.pumpAndSettle();
  await Future<void>.delayed(const Duration(seconds: 2));
  await platform.postSample(
    sidecarUrl: _sidecarUrl,
    caseId: caseId,
    label: label,
  );
}
