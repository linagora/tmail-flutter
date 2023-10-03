import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rule_filter/rule_filter/rule_append_in.dart';

part 'rule_action.g.dart';

@JsonSerializable(explicitToJson: true)
class RuleAction with EquatableMixin {
  final RuleAppendIn appendIn;
  @JsonKey(includeIfNull: false)
  final bool? markAsSeen;
  @JsonKey(includeIfNull: false)
  final bool? markAsImportant;
  @JsonKey(includeIfNull: false)
  final bool? reject;

  RuleAction({
    required this.appendIn,
    this.markAsSeen,
    this.markAsImportant,
    this.reject,
  });

  @override
  List<Object?> get props => [
        appendIn,
      ];

  factory RuleAction.fromJson(Map<String, dynamic> json) =>
      _$RuleActionFromJson(json);

  Map<String, dynamic> toJson() => _$RuleActionToJson(this);
}
