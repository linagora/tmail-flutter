import '../exceptions/workplace_exceptions.dart';
import 'drive_document.dart';

extension DriveDocumentExtension on DriveDocument {
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
