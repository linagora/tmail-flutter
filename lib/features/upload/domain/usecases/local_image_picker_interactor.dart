import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/pick_file_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/platform_file_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_image_picker_state.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/web_pick_options.dart';

class LocalImagePickerInteractor {

  LocalImagePickerInteractor();

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(LocalImagePickerLoading());

      final pickedFile = await FilePicker.pickFile(
        type: FileType.image,
        webOptions: lazyWebPickOptions(),
      );

      if (pickedFile != null) {
        final fileInfo = await pickedFile.toFileInfo();
        yield Right<Failure, Success>(LocalImagePickerSuccess(fileInfo));
      } else {
        yield Left<Failure, Success>(LocalImagePickerFailure(const PickFileCanceledException()));
      }
    } catch (exception) {
      yield Left<Failure, Success>(LocalImagePickerFailure(exception));
    }
  }
}
