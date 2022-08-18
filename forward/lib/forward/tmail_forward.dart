import 'package:forward/forward/converter/forward_id_coverter.dart';
import 'package:forward/forward/forward.dart';
import 'package:forward/forward/forward_id.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tmail_forward.g.dart';

@ForwardIdConverter()
@JsonSerializable()
class TMailForward extends Forward {
  final ForwardId id;
  final bool localCopy;
  final Set<String> forwards;
  TMailForward({
    required this.id,
    required this.localCopy,
    required this.forwards,
  });

  factory TMailForward.fromJson(Map<String, dynamic> json) =>
      _$TMailForwardFromJson(json);

  Map<String, dynamic> toJson() => _$TMailForwardToJson(this);

  @override
  List<Object?> get props => [
    id,
    localCopy,
    forwards,
  ];
}
