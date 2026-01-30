import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'keyword_config.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class KeywordConfig with EquatableMixin {
  final List<String> includeList;
  final List<String> excludeList;

  const KeywordConfig({
    this.includeList = const [],
    this.excludeList = const [],
  });

  factory KeywordConfig.fromJson(Map<String, dynamic> json) =>
      _$KeywordConfigFromJson(json);

  Map<String, dynamic> toJson() => _$KeywordConfigToJson(this);

  @override
  List<Object?> get props => [includeList, excludeList];
}
