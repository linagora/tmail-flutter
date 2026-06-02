import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'drive_document.g.dart';

@JsonSerializable(createToJson: false)
class DriveDocument with EquatableMixin {
  final String id;
  final String name;
  final int size;
  final String mimeType;
  final Uri? sharingLink;
  final Uri? downloadLink;

  const DriveDocument({
    required this.id,
    required this.name,
    required this.size,
    required this.mimeType,
    this.sharingLink,
    this.downloadLink,
  });

  Uri? get attachmentUrl => sharingLink ?? downloadLink;

  factory DriveDocument.fromJson(Map<String, dynamic> json) => _$DriveDocumentFromJson(json);

  @override
  List<Object?> get props => [id, name, size, mimeType, sharingLink, downloadLink];
}
