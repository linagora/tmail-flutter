import 'package:core/data/constants/constant.dart';
import 'package:core/domain/preview/document_uti.dart';
import 'package:core/domain/preview/supported_preview_file_types.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:http_parser/http_parser.dart';

extension MediaTypeExtension on MediaType {
  bool isAndroidSupportedPreview() => SupportedPreviewFileTypes.androidSupportedTypes.contains(mimeType);

  bool isIOSSupportedPreview() => SupportedPreviewFileTypes.iOSSupportedTypes.containsKey(mimeType);

  bool isImageFile() => SupportedPreviewFileTypes.imageMimeTypes.contains(mimeType);

  bool isDocFile() => SupportedPreviewFileTypes.docMimeTypes.contains(mimeType);

  bool isPowerPointFile() => SupportedPreviewFileTypes.pptMimeTypes.contains(mimeType);

  bool isExcelFile() => SupportedPreviewFileTypes.xlsMimeTypes.contains(mimeType);

  bool isZipFile() => SupportedPreviewFileTypes.zipMimeTypes.contains(mimeType);

  bool isRtfFile() => SupportedPreviewFileTypes.rtfMimeTypes.contains(mimeType);

  bool isTextFile() => SupportedPreviewFileTypes.textMimeTypes.contains(mimeType);

  bool isJsonFile() => SupportedPreviewFileTypes.jsonMimeTypes.contains(mimeType);

  DocumentUti getDocumentUti() => DocumentUti(SupportedPreviewFileTypes.iOSSupportedTypes[mimeType]);

  String getIcon(ImagePaths imagePaths, {String? fileName}) {
    if (isPDFFile(fileName: fileName) == true || isRtfFile()) {
      return imagePaths.icFilePdf;
    } else if (isDocFile()) {
      return imagePaths.icFileDocx;
    } else if (isExcelFile()) {
      return imagePaths.icFileXlsx;
    } else if (isPowerPointFile()) {
      return imagePaths.icFilePptx;
    } else if (isZipFile()) {
      return imagePaths.icFileZip;
    } else if (isImageSupportedPreview(fileName: fileName)) {
      return imagePaths.icFilePng;
    } else {
      return imagePaths.icFileEPup;
    }
  }

  bool isPDFFile({required String? fileName}) =>
      mimeType == Constant.pdfMimeType ||
      (mimeType == Constant.octetStreamMimeType &&
          fileName?.endsWith(Constant.pdfExtension) == true);

  bool get isEMLFile => mimeType == Constant.emlMimeType;

  bool isHTMLFile({required String? fileName}) =>
      mimeType == Constant.textHtmlMimeType ||
      (mimeType == Constant.octetStreamMimeType &&
          fileName?.endsWith(Constant.htmlExtension) == true);

  bool isImageSupportedPreview({required String? fileName}) =>
      isImageFile() ||
      (mimeType == Constant.octetStreamMimeType &&
          fileName != null &&
          SupportedPreviewFileTypes.imageMimeTypes
              .contains(fileName.imageMimeType));
}
