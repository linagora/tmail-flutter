
import 'package:core/core.dart';
import 'package:model/email/attachment.dart';

extension AttachmentExtension on Attachment {

  String getIcon(ImagePaths imagePaths) {
    final mediaType = type;
    log('AttachmentExtension::getIcon(): mediaType: $mediaType');
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
}