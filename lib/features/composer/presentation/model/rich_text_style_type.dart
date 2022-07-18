
import 'package:core/presentation/resources/image_paths.dart';

enum RichTextStyleType {
  bold,
  italic,
  underline;

  String get commandAction {
    switch (this) {
      case bold:
        return 'bold';
      case italic:
        return 'italic';
      case underline:
        return 'underline';
      default:
        return '';
    }
  }

  String getIcon(ImagePaths imagePaths) {
    switch (this) {
      case bold:
        return imagePaths.icStyleBold;
      case italic:
        return imagePaths.icStyleItalic;
      case underline:
        return imagePaths.icStyleUnderline;
      default:
        return '';
    }
  }
}