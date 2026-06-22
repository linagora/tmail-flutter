import 'drive_document.dart';

extension DriveDocumentExtension on DriveDocument {
  // Strip chars that break the structured header: quote closes the field, semicolon
  // starts a new param, CRLF enables header-injection in HTTP contexts.
  static String _sanitizeHeaderParam(String value) =>
      value.replaceAll(RegExp(r'["\r\n;]'), '');

  // Only allow https:// URLs to prevent javascript:, data:, and other dangerous schemes.
  static Uri? _sanitizeUrl(Uri? uri) {
    if (uri == null) return null;
    return uri.scheme == 'https' ? uri : null;
  }

  String? get linkedFileHeader {
    final url = _sanitizeUrl(attachmentUrl);
    if (url == null) return null;
    final safeName = _sanitizeHeaderParam(name);
    final safeMimeType = _sanitizeHeaderParam(mimeType);
    return 'url=${url.toString()}; filename="$safeName"; '
        'type="$safeMimeType"; size=$size';
  }
  
  Uri? get attachmentUrl => sharingLink ?? downloadLink;
}
