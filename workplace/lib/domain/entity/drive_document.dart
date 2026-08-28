import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'drive_document.g.dart';

@JsonSerializable(createToJson: false)
class DriveDocument with EquatableMixin {
  final String id;
  final String name;
  final int size;
  final String? mimeType;
  final Uri? sharingLink;
  final Uri? downloadLink;
  final DriveDocumentThumbnail? thumbnail;

  const DriveDocument({
    required this.id,
    required this.name,
    required this.size,
    this.mimeType,
    this.sharingLink,
    this.downloadLink,
    this.thumbnail,
  });

  factory DriveDocument.fromJson(Map<String, dynamic> json) => _$DriveDocumentFromJson(json);

  @override
  List<Object?> get props => [id, name, size, mimeType, sharingLink, downloadLink, thumbnail];
}

@JsonSerializable(createToJson: false)
class DriveDocumentThumbnail with EquatableMixin {
  final Uri? link;

  const DriveDocumentThumbnail({this.link});

  factory DriveDocumentThumbnail.fromJson(Map<String, dynamic> json) =>
      _$DriveDocumentThumbnailFromJson(json);

  @override
  List<Object?> get props => [link];
}
