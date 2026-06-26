import 'package:model/upload/file_info.dart';
import 'package:workplace/domain/entity/drive_document.dart';

abstract class DriveFileRepository {
  Future<FileInfo> downloadFile(DriveDocument doc);
}
