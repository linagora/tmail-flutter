
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/pick_file_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/platform_file_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_file_picker_state.dart';

class LocalFilePickerInteractor {

  LocalFilePickerInteractor();

  Stream<Either<Failure, Success>> execute({FileType fileType = FileType.any}) async* {
    try {
      yield Right<Failure, Success>(LocalFilePickerLoading());

      final filesResult = await FilePicker.platform.pickFiles(
        type: fileType,
        allowMultiple: true,
        withData: PlatformInfo.isWeb,
        withReadStream: PlatformInfo.isMobile
      );

      if (filesResult?.files.isNotEmpty == true) {
        final listFileInfo = filesResult!.files
          .map((platformFile) => platformFile.toFileInfo())
          .toList();
        yield Right<Failure, Success>(LocalFilePickerSuccess(listFileInfo));
      } else {
        yield Left<Failure, Success>(LocalFilePickerFailure(PickFileCanceledException()));
      }
    } catch (exception) {
      yield Left<Failure, Success>(LocalFilePickerFailure(exception));
    }
  }
}