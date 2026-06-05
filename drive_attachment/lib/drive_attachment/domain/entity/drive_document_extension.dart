import 'package:drive_attachment/drive_attachment/domain/entity/drive_document.dart';

extension DriveDocumentExtension on DriveDocument {
  String get linkedFileHeader {
    final url = attachmentUrl;
    return 'url=${url?.toString()}; filename="$name"; '
        'type="$mimeType"; size=$size';
  }
}
