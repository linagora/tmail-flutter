import 'package:core/utils/html/platform_host_script_nonce.dart';

/// Host-page script nonce used to stamp tmail-owned viewer and print scripts.
abstract final class HostScriptNonce {
  static final RegExp pattern = RegExp(r'^[A-Za-z0-9+/=_-]+$');

  static bool isValid(String? nonce) =>
      nonce != null && pattern.hasMatch(nonce);

  /// First valid host script `.nonce`, or null when none is usable.
  static String? read() => readPlatformHostScriptNonce();

  /// Stamps tmail-owned script tags. Callers must not pass email content.
  static String stampOwnScriptTags(String scripts, String? nonce) {
    if (!isValid(nonce)) return scripts;
    return scripts.replaceAll('<script', '<script nonce="$nonce"');
  }
}
