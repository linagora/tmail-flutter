import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/state/upload_attachment_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_attachment_interactor.dart';

class UploadMultipleAttachmentInteractor {
  final UploadAttachmentInteractor _uploadAttachmentInteractor;

  UploadMultipleAttachmentInteractor(this._uploadAttachmentInteractor);

  Stream<Either<Failure, Success>> execute(List<FileInfo> listFiles, AccountId accountId, Uri uploadUrl) async* {
    try {
      yield Right<Failure, Success>(UploadingAttachmentState());
      final listResult = await Future.wait(
        listFiles.map((fileInfo) async {
          final result = await _uploadAttachmentInteractor.execute(fileInfo, accountId, uploadUrl).toList();
          return result.first;
        })
      );
      if (listResult.length == 1) {
        yield listResult.first;
      } else {
        final listResultSuccess = listResult.where((either) => either.isRight()).toList();
        if (listResultSuccess.length == listResult.length) {
          yield Right<Failure, Success>(UploadMultipleAttachmentAllSuccess(listResultSuccess));
        } else if (listResultSuccess.isEmpty) {
          yield Left<Failure, Success>(UploadMultipleAttachmentAllFailure(listResult));
        } else {
          yield Right<Failure, Success>(UploadMultipleAttachmentHasSomeFailure(listResultSuccess));
        }
      }
    } catch (e) {
      yield Left<Failure, Success>(UploadMultipleAttachmentFailure(e));
    }
  }
}