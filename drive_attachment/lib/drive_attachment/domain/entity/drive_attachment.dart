import 'package:drive_attachment/drive_attachment/domain/entity/drive_document.dart';
import 'package:equatable/equatable.dart';

class DriveAttachment with EquatableMixin {
  final DriveDocument document;

  const DriveAttachment({required this.document});

  String get linkedFileHeader {
    final url = document.attachmentUrl;
    return 'url=${url?.toString()}; filename="${document.name}"; '
        'type="${document.mimeType}"; size=${document.size}';
  }

  @override
  List<Object?> get props => [document];
}
