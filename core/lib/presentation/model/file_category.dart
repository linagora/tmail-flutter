import 'package:core/presentation/resources/image_paths.dart';

enum FileCategory {
  pdf,
  document,
  documentODT,
  spreadsheet,
  spreadsheetODS,
  presentation,
  presentationODP,
  image,
  video,
  audio,
  archive,
  text,
  code,
  other;

  String getIconPath(ImagePaths imagePaths) {
    switch (this) {
      case FileCategory.pdf:
        return imagePaths.icFilePdf;
      case FileCategory.document:
        return imagePaths.icFileDoc;
      case FileCategory.documentODT:
        return imagePaths.icFileODT;
      case FileCategory.spreadsheet:
        return imagePaths.icFileExcel;
      case FileCategory.spreadsheetODS:
        return imagePaths.icFileODS;
      case FileCategory.presentation:
        return imagePaths.icFilePowerPoint;
      case FileCategory.presentationODP:
        return imagePaths.icFileODP;
      case FileCategory.image:
        return imagePaths.icFileImage;
      case FileCategory.video:
        return imagePaths.icFileVideo;
      case FileCategory.audio:
        return imagePaths.icFileAudio;
      case FileCategory.archive:
        return imagePaths.icFileZip;
      case FileCategory.text:
        return imagePaths.icFileText;
      case FileCategory.code:
        return imagePaths.icFileCode;
      case FileCategory.other:
        return imagePaths.icFileDefault;
    }
  }
}
