
import 'package:file_picker/file_picker.dart';

extension ListPlatformFileExtensions on List<PlatformFile> {
  int get totalFilesSize => fold<int>(0, (sum, file) => sum + file.size);
}