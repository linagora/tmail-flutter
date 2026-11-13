import 'package:core/utils/html/platform_host_script_nonce.dart';

/// Host-page script nonce for tmail-owned viewer and print scripts.
/// Grammar and stamp rules mirror html-editor-enhanced NonceUtils (no shared package).
abstract final class HostScriptNonce {
  static final RegExp pattern = RegExp(r'^[A-Za-z0-9+/=_-]+$');
  static final RegExp _scriptOpenTag =
      RegExp(r'<script(?=[\s>])', caseSensitive: false);

  static bool isValid(String? nonce) =>
      nonce != null && pattern.hasMatch(nonce);

  /// First valid host script `.nonce`, or null when none is usable.
  static String? read() => readPlatformHostScriptNonce();

  /// Stamps tmail-owned script tags. Callers must not pass email content.
  static String stampOwnScriptTags(String scripts, String? nonce) {
    if (!isValid(nonce)) return scripts;
    return scripts.replaceAll(_scriptOpenTag, '<script nonce="$nonce"');
  }
}
