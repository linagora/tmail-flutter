import 'workplace_upload_source.dart';

/// What one file upload needs, grouped to keep uploadFile's own arg count low.
class WorkplaceUploadFileSpec {
  final String fileName;
  final String mimeType;
  final int fileSize;
  final WorkplaceUploadSource source;

  const WorkplaceUploadFileSpec({
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    required this.source,
  });
}
