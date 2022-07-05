
import 'package:equatable/equatable.dart';

class UploadTaskId extends Equatable {
  final String id;

  const UploadTaskId(this.id);

  factory UploadTaskId.undefined() => const UploadTaskId('');

  @override
  List<Object> get props => [id];
}