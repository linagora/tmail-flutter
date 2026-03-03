import 'package:core/domain/exceptions/app_base_exception.dart';

abstract class FileException extends AppBaseException {
  const FileException(super.message);
}

class NotFoundFileInFolderException extends FileException {
  NotFoundFileInFolderException() : super('No files found in the folder');

  @override
  String get exceptionName => 'NotFoundFileInFolderException';
}

class UserCancelShareFileException extends FileException {
  UserCancelShareFileException() : super('User cancel share file');

  @override
  String get exceptionName => 'UserCancelShareFileException';
}
