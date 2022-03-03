
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_file_picker_state.dart';

class LocalFilePickerInteractor {

  LocalFilePickerInteractor();

  Stream<Either<Failure, Success>> execute({FileType fileType = FileType.any}) async* {
    try {
      final filesResult = await FilePicker.platform.pickFiles(type: fileType, allowMultiple: true, withReadStream: true);
      if (filesResult != null && filesResult.files.isNotEmpty) {
      final fileInfoResults = filesResult.files
        .map((platformFile) => FileInfo(
          platformFile.name,
          kIsWeb ? '' : platformFile.path ?? '',
          platformFile.size,
          readStream: platformFile.readStream)).toList();
        yield Right<Failure, Success>(LocalFilePickerSuccess(fileInfoResults));
      } else {
        yield Left<Failure, Success>(LocalFilePickerCancel());
      }
    } catch (exception) {
      yield Left<Failure, Success>(LocalFilePickerFailure(exception));
    }
  }
}