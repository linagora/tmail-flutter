import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';

extension ListUploadFileStateExtension on List<UploadFileState> {

  num get totalSize {
    if (isNotEmpty) {
      final currentListSize = map((file) => file.fileSize).toList();
      final totalSize = currentListSize.reduce((sum, size) => sum + size);
      return totalSize;
    }
    return 0;
  }
}