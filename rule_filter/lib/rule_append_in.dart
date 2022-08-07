import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/http/converter/mailbox_id_converter.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rule_append_in.g.dart';

@MailboxIdConverter()
@JsonSerializable()
class RuleAppendIn with EquatableMixin {
  final List<MailboxId> mailboxIds;

  RuleAppendIn({
    required this.mailboxIds,
  });

  @override
  List<Object?> get props => [
        mailboxIds,
      ];

  factory RuleAppendIn.fromJson(Map<String, dynamic> json) =>
      _$RuleAppendInFromJson(json);

  Map<String, dynamic> toJson() => _$RuleAppendInToJson(this);
}
