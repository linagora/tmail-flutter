import 'package:equatable/equatable.dart';

abstract class FileException with EquatableMixin implements Exception {
  final String message;

  FileException(this.message);

  @override
  String toString() => message;

  @override
  List<Object> get props => [message];
}

class NotFoundFileInFolderException extends FileException {
  NotFoundFileInFolderException() : super('No files found in the folder');
}

class UserCancelShareFileException extends FileException {
  UserCancelShareFileException() : super('User cancel share file');
}