import 'package:drive_attachment/drive_attachment/domain/entity/drive_document.dart';
import 'package:drive_attachment/drive_attachment/domain/entity/drive_document_extension.dart';
import 'package:equatable/equatable.dart';

class DriveAttachment with EquatableMixin {
  final DriveDocument document;

  const DriveAttachment({required this.document});

  String get linkedFileHeader => document.linkedFileHeader;

  @override
  List<Object?> get props => [document];
}
