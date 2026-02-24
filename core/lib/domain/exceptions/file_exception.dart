import 'package:core/domain/exceptions/app_base_exception.dart';
import 'package:equatable/equatable.dart';

abstract class FileException extends AppBaseException with EquatableMixin {
  const FileException(super.message);

  @override
  List<Object?> get props => [message, exceptionName];
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
