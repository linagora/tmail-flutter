import 'drive_document.dart';

extension DriveDocumentExtension on DriveDocument {
  Uri? get attachmentUrl => sharingLink ?? downloadLink;
}
