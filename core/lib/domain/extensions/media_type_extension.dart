import 'package:core/domain/preview/document_uti.dart';
import 'package:core/domain/preview/supported_preview_file_types.dart';
import 'package:http_parser/http_parser.dart';

extension MediaTypeExtension on MediaType {
  bool isAndroidSupportedPreview() => SupportedPreviewFileTypes.androidSupportedTypes.contains(mimeType);

  bool isIOSSupportedPreview() => SupportedPreviewFileTypes.iOSSupportedTypes.containsKey(mimeType);

  bool isImageFile() => SupportedPreviewFileTypes.imageMimeTypes.contains(mimeType);

  bool isDocFile() => SupportedPreviewFileTypes.docMimeTypes.contains(mimeType);

  bool isPowerPointFile() => SupportedPreviewFileTypes.pptMimeTypes.contains(mimeType);

  bool isExcelFile() => SupportedPreviewFileTypes.xlsMimeTypes.contains(mimeType);

  bool isZipFile() => SupportedPreviewFileTypes.zipMimeTypes.contains(mimeType);

  bool isPdfFile() => SupportedPreviewFileTypes.pdfMimeTypes.contains(mimeType);

  DocumentUti getDocumentUti() => DocumentUti(SupportedPreviewFileTypes.iOSSupportedTypes[mimeType]);
}
