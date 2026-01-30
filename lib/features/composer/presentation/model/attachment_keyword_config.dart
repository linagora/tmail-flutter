import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attachment_keyword_config.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class AttachmentKeywordConfig with EquatableMixin {
  final List<String> includeList;
  final List<String> excludeList;

  AttachmentKeywordConfig({
    List<String> includeList = const [],
    List<String> excludeList = const [],
  })  : includeList = List.unmodifiable(includeList),
        excludeList = List.unmodifiable(excludeList);

  factory AttachmentKeywordConfig.fromJson(Map<String, dynamic> json) =>
      _$AttachmentKeywordConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentKeywordConfigToJson(this);

  @override
  List<Object?> get props => [includeList, excludeList];
}
