
import 'package:core/domain/extensions/media_type_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/app_logger.dart';
import 'package:http_parser/http_parser.dart';
import 'package:model/email/attachment.dart';

extension AttachmentExtension on Attachment {

  String getIcon(ImagePaths imagePaths, {MediaType? fileMediaType}) {
    final mediaType = type ?? fileMediaType;
    log('AttachmentExtension::getIcon(): mediaType: $mediaType');
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

  bool get isDisplayedPDFIcon => type?.mimeType == 'application/pdf' ||
    (type?.mimeType == 'application/octet-stream' && name?.endsWith('.pdf') == true);
}