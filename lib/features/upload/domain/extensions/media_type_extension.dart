import 'package:core/domain/extensions/media_type_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:http_parser/http_parser.dart';

extension MediaTypeExtension on MediaType {
  String getIcon(ImagePaths imagePaths, {String? fileName}) {
    if (validatePDFIcon(fileName: fileName) == true) {
      return imagePaths.icFilePdf;
    } else if (isDocFile()) {
      return imagePaths.icFileDocx;
    } else if (isExcelFile()) {
      return imagePaths.icFileXlsx;
    } else if (isPowerPointFile()) {
      return imagePaths.icFilePptx;
    } else if (isPdfFile()) {
      return imagePaths.icFilePdf;
    } else if (isZipFile()) {
      return imagePaths.icFileZip;
    } else if (isImageFile()) {
      return imagePaths.icFilePng;
    } else {
      return imagePaths.icFileEPup;
    }
  }

  bool validatePDFIcon({required String? fileName}) => mimeType == 'application/pdf' ||
    (mimeType == 'application/octet-stream' && fileName?.endsWith('.pdf') == true);
}
