import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rule_filter/rule_filter/rule_append_in.dart';

part 'rule_action.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RuleAction with EquatableMixin {
  final RuleAppendIn appendIn;
  final bool? markAsSeen;
  final bool? markAsImportant;
  final bool? reject;
  final List<String>? withKeywords;

  RuleAction({
    required this.appendIn,
    this.markAsSeen,
    this.markAsImportant,
    this.reject,
    this.withKeywords,
  });

  @override
  List<Object?> get props => [
    appendIn,
    markAsSeen,
    markAsImportant,
    reject,
    withKeywords,
  ];

  factory RuleAction.fromJson(Map<String, dynamic> json) =>
      _$RuleActionFromJson(json);

  Map<String, dynamic> toJson() => _$RuleActionToJson(this);
}
