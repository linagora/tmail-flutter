import 'package:flutter/foundation.dart';

bool isValidDriveClient(String? client) =>
    client != null && client.trim().isNotEmpty && client != '*';

/// Validates a postMessage/JS-channel origin against the resolved intent.
abstract class DriveOriginValidator {
  const DriveOriginValidator();

  /// Shared rule set; platform variants only override [matchesClient].
  bool isValid(
    String? origin, {
    required String intentOrigin,
    required String? intentClient,
  }) {
    if (origin == null) return false;
    if (origin == intentOrigin) return true;
    if (matchesClient(origin, intentClient)) return true;
    // Dev/fake intents (data: URI, no server-provided client) — the shim/
    // postMessage sends '*' as targetOrigin in that case.
    return intentOrigin == 'null' && origin == '*';
  }

  /// Extra origin match beyond [intentOrigin]. No-op on web.
  @protected
  bool matchesClient(String origin, String? intentClient) => false;
}

/// Web postMessage origins always equal the intent origin — no extra match.
class WebDriveOriginValidator extends DriveOriginValidator {
  const WebDriveOriginValidator();
}

/// Mobile JS channel additionally allows the intent's declared client id.
class MobileDriveOriginValidator extends DriveOriginValidator {
  const MobileDriveOriginValidator();

  @override
  bool matchesClient(String origin, String? intentClient) =>
      isValidDriveClient(intentClient) && origin == intentClient;
}
