import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/repository/drive_file_repository.dart';
import 'package:workplace/domain/state/download_drive_file_state.dart';

class DownloadDriveFileInteractor {
  final DriveFileRepository _repository;

  DownloadDriveFileInteractor(this._repository);

  Stream<Either<Failure, Success>> execute(DriveDocument doc) async* {
    try {
      yield Right(DownloadingDriveFile());
      final fileInfo = await _repository.downloadFile(doc);
      yield Right(DownloadDriveFileSuccess(fileInfo));
    } catch (e) {
      yield Left(DownloadDriveFileFailure(e));
    }
  }
}
