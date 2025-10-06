import 'package:core/data/constants/constant.dart';
import 'package:core/domain/preview/document_uti.dart';
import 'package:core/domain/preview/supported_preview_file_types.dart';
import 'package:core/presentation/model/file_category.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:http_parser/http_parser.dart';

extension MediaTypeExtension on MediaType {
  bool isJsonFile() => SupportedPreviewFileTypes.jsonMimeTypes.contains(mimeType);

  DocumentUti getDocumentUti() => DocumentUti(SupportedPreviewFileTypes.iOSSupportedTypes[mimeType]);

  String getIcon(ImagePaths imagePaths, {String? fileName}) {
    final category = getFileCategory(fileName: fileName);
    return category.getIconPath(imagePaths);
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

  FileCategory getFileCategory({String? fileName}) {
    String? ext;

    if (fileName != null && fileName.contains('.')) {
      ext = fileName.split('.').last.toLowerCase();
    }

    switch (ext) {
      case 'pdf':
        return FileCategory.pdf;
      case 'doc':
      case 'docx':
      case 'rtf':
        return FileCategory.document;
      case 'odt':
        return FileCategory.documentODT;
      case 'xls':
      case 'xlsx':
      case 'csv':
      case 'tsv':
        return FileCategory.spreadsheet;
      case 'ods':
        return FileCategory.spreadsheetODS;
      case 'ppt':
      case 'pptx':
      return FileCategory.presentation;
      case 'odp':
        return FileCategory.presentationODP;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'svg':
      case 'webp':
      case 'heic':
      case 'heif':
      case 'avif':
      case 'tiff':
        return FileCategory.image;
      case 'mp3':
      case 'wav':
      case 'ogg':
      case 'm4a':
      case 'aac':
      case 'flac':
        return FileCategory.audio;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'webm':
      case 'wmv':
        return FileCategory.video;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
      case 'bz2':
        return FileCategory.archive;
      case 'txt':
      case 'md':
      case 'log':
        return FileCategory.text;
      case 'js':
      case 'ts':
      case 'json':
      case 'html':
      case 'css':
      case 'xml':
      case 'java':
      case 'kt':
      case 'dart':
      case 'py':
      case 'c':
      case 'cpp':
      case 'h':
      case 'cs':
      case 'swift':
      case 'go':
      case 'rb':
      case 'php':
      case 'sh':
      case 'yml':
      case 'yaml':
        return FileCategory.code;
      case 'apk':
      case 'ipa':
      case 'exe':
      case 'dmg':
        return FileCategory.other;
    }

    final lowerType = mimeType.toLowerCase();

    if (lowerType == 'application/pdf') return FileCategory.pdf;
    if (lowerType.startsWith('image/')) return FileCategory.image;
    if (lowerType.startsWith('audio/')) return FileCategory.audio;
    if (lowerType.startsWith('video/')) return FileCategory.video;
    if (lowerType.startsWith('text/')) return FileCategory.text;

    if (lowerType.contains('zip') || lowerType.contains('compressed')) {
      return FileCategory.archive;
    }

    if (lowerType.contains('msword') ||
        lowerType.contains('wordprocessingml')) {
      return FileCategory.document;
    }

    if (lowerType.contains('spreadsheetml') ||
        lowerType.contains('excel') ||
        lowerType.contains('csv')) {
      return FileCategory.spreadsheet;
    }

    if (lowerType.contains('presentationml') ||
        lowerType.contains('powerpoint')) {
      return FileCategory.presentation;
    }

    if (lowerType == 'application/octet-stream') {
      return FileCategory.other;
    }

    return FileCategory.other;
  }
}
