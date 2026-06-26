import 'package:model/upload/file_info.dart';
import 'package:workplace/data/datasource/drive_file_datasource.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/repository/drive_file_repository.dart';

class DriveFileRepositoryImpl implements DriveFileRepository {
  final DriveFileDatasource _datasource;

  DriveFileRepositoryImpl(this._datasource);

  @override
  Future<FileInfo> downloadFile(DriveDocument doc) {
    return _datasource.downloadFile(doc);
  }
}
