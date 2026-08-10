import '../exceptions/workplace_exceptions.dart';
import 'drive_document.dart';

extension DriveDocumentExtension on DriveDocument {
  // ASCII values → quoted-string with backslash escaping (RFC 2822 §3.2.5).
  // Non-ASCII values → RFC 2231 encoded param (RFC 5987), no quotes.
  static String _formatParam(String paramName, String value) {
    final hasNonAscii = value.runes.any((r) => r > 127);
    if (hasNonAscii) {
      return "$paramName*=UTF-8''${Uri.encodeComponent(value)}";
    }
    // Strip control chars, quotes, semicolons; escape backslash for quoted-string.
    final safe = value
        .replaceAll(RegExp(r'[\x00-\x1F\x7F";\r\n]'), '')
        .replaceAll('\\', '\\\\');
    return '$paramName="$safe"';
  }

  // Only allow https:// URLs to prevent javascript:, data:, and other dangerous schemes.
  static Uri? _sanitizeUrl(Uri? uri) {
    if (uri == null) return null;
    return uri.scheme == 'https' ? uri : null;
  }

  String? get linkedFileHeader {
    final url = _sanitizeUrl(attachmentUrl);
    if (url == null) return null;

    // Fold between params with CRLF + tab (RFC 2822 §2.1.1 line folding).
    return [
      'url=${url.toString()}',
      _formatParam('filename', name),
      _formatParam('type', mimeType),
      'size=$size',
    ].join(';\r\n\t');
  }

  Uri? get attachmentUrl => sharingLink ?? downloadLink;

  /// The link a stager downloads from. Throws
  /// [DriveDownloadNullAttachmentException] when absent, and
  /// [DriveDownloadInsecureLinkException] for non-https in release mode
  /// (http stays allowed in dev for local backends).
  Uri resolveDownloadLinkForStaging({required bool isReleaseMode}) {
    final link = downloadLink;
    if (link == null) {
      throw DriveDownloadNullAttachmentException();
    }
    if (isReleaseMode && !link.isScheme('https')) {
      throw DriveDownloadInsecureLinkException();
    }
    return link;
  }
}
