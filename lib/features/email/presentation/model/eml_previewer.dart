
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'eml_previewer.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class EMLPreviewer with EquatableMixin {
  final String title;
  final String content;

  EMLPreviewer({required this.title, required this.content});

  factory EMLPreviewer.fromJson(Map<String, dynamic> json) => _$EMLPreviewerFromJson(json);

  Map<String, dynamic> toJson() => _$EMLPreviewerToJson(this);
  
  @override
  List<Object?> get props => [title, content];
}