import 'package:forward/forward/converter/rule_filter_id_coverter.dart';
import 'package:forward/forward/forward.dart';
import 'package:forward/forward/forward_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tmail_forward.g.dart';

@ForwardIdConverter()
@JsonSerializable()
class TmailForward extends Forward {
  final ForwardId id;
  final bool localCopy;
  final Set<String> forwards;
  TmailForward({
    required this.id,
    required this.localCopy,
    required this.forwards,
  });

  factory TmailForward.fromJson(Map<String, dynamic> json) =>
      _$TmailForwardFromJson(json);

  Map<String, dynamic> toJson() => _$TmailForwardToJson(this);

  @override
  List<Object?> get props => [
    id,
    localCopy,
    forwards,
  ];
}
