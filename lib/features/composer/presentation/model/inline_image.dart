
import 'package:equatable/equatable.dart';
import 'package:model/upload/file_info.dart';

class InlineImage with EquatableMixin {
  final FileInfo fileInfo;
  final String? base64Uri;

  InlineImage({
    required this.fileInfo,
    this.base64Uri,
  });

  @override
  List<Object?> get props => [
    fileInfo,
    base64Uri
  ];
}