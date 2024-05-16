import 'package:core/data/constants/constant.dart';
import 'package:core/domain/extensions/media_type_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:http_parser/http_parser.dart';
import 'package:model/email/attachment.dart';

extension AttachmentExtension on Attachment {

  String getIcon(ImagePaths imagePaths, {MediaType? fileMediaType}) {
    final mediaType = type ?? fileMediaType;

    if (isDisplayedPDFIcon) {
      return imagePaths.icFilePdf;
    }

    if (mediaType == null) {
      return imagePaths.icFileEPup;
    }
    if (mediaType.isDocFile()) {
      return imagePaths.icFileDocx;
    } else if (mediaType.isExcelFile()) {
      return imagePaths.icFileXlsx;
    } else if (mediaType.isPowerPointFile()) {
      return imagePaths.icFilePptx;
    } else if (mediaType.isPdfFile()) {
      return imagePaths.icFilePdf;
    } else if (mediaType.isZipFile()) {
      return imagePaths.icFileZip;
    } else if (mediaType.isImageFile()) {
      return imagePaths.icFilePng;
    }
    return imagePaths.icFileEPup;
  }

  bool get isDisplayedPDFIcon => type?.mimeType == Constant.pdfMimeType
    || (type?.mimeType == Constant.octetStreamMimeType
          && name?.endsWith(Constant.pdfExtension) == true);
}