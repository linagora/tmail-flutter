import 'drive_document.dart';

extension DriveDocumentExtension on DriveDocument {
  String get linkedFileHeader {
    final url = attachmentUrl;
    return 'url=${url?.toString()}; filename="$name"; '
        'type="$mimeType"; size=$size';
  }
  
  Uri? get attachmentUrl => sharingLink ?? downloadLink;
}
