import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/pick_file_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/platform_file_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_image_picker_state.dart';

class LocalImagePickerInteractor {

  LocalImagePickerInteractor();

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(LocalImagePickerLoading());

      final filePickerResult = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withReadStream: PlatformInfo.isMobile,
        withData: PlatformInfo.isWeb
      );

      if (filePickerResult?.files.isNotEmpty == true) {
        final fileInfo = filePickerResult!.files.first.toFileInfo();
        yield Right<Failure, Success>(LocalImagePickerSuccess(fileInfo));
      } else {
        yield Left<Failure, Success>(LocalImagePickerFailure(PickFileCanceledException()));
      }
    } catch (exception) {
      yield Left<Failure, Success>(LocalImagePickerFailure(exception));
    }
  }
}