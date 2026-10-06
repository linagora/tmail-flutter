
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/pick_file_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/platform_file_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_file_picker_state.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/web_pick_options.dart';

class LocalFilePickerInteractor {

  LocalFilePickerInteractor();

  Stream<Either<Failure, Success>> execute({FileType fileType = FileType.any}) async* {
    try {
      yield Right<Failure, Success>(LocalFilePickerLoading());

      final pickedFiles = await FilePicker.pickFiles(
        type: fileType,
        webOptions: lazyWebPickOptions(),
      );

      if (pickedFiles.isNotEmpty) {
        final listFileInfo = await Future.wait(
          pickedFiles.map((platformFile) => platformFile.toFileInfo()),
        );
        yield Right<Failure, Success>(LocalFilePickerSuccess(listFileInfo));
      } else {
        yield Left<Failure, Success>(LocalFilePickerFailure(const PickFileCanceledException()));
      }
    } catch (exception) {
      yield Left<Failure, Success>(LocalFilePickerFailure(exception));
    }
  }
}
