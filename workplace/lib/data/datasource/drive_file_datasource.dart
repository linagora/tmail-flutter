import 'package:model/upload/file_info.dart';
import 'package:workplace/domain/entity/drive_document.dart';

abstract class DriveFileDatasource {
  Future<FileInfo> downloadFile(DriveDocument doc);
}
