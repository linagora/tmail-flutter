
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_file_picker_state.dart';

class LocalFilePickerInteractor {

  LocalFilePickerInteractor();

  Stream<Either<Failure, Success>> execute({FileType fileType = FileType.any}) async* {
    try {
      final filesResult = await FilePicker.platform.pickFiles(
        type: fileType,
        allowMultiple: true,
        withData: PlatformInfo.isWeb
      );
      if (filesResult != null && filesResult.files.isNotEmpty) {
      final fileInfoResults = filesResult.files
        .map((platformFile) => FileInfo(
          platformFile.name,
          PlatformInfo.isWeb ? '' : platformFile.path ?? '',
          platformFile.size,
          bytes: PlatformInfo.isWeb ? platformFile.bytes : null
        ))
        .toList();
        yield Right<Failure, Success>(LocalFilePickerSuccess(fileInfoResults));
      } else {
        yield Left<Failure, Success>(LocalFilePickerCancel());
      }
    } catch (exception) {
      yield Left<Failure, Success>(LocalFilePickerFailure(exception));
    }
  }
}