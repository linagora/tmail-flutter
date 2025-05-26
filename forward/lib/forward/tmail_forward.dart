import 'package:forward/forward/converter/forward_id_nullable_converter.dart';
import 'package:forward/forward/forward.dart';
import 'package:forward/forward/forward_id.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tmail_forward.g.dart';

@ForwardIdNullableConverter()
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TMailForward extends Forward {
  final ForwardId? id;
  final bool? localCopy;
  final Set<String>? forwards;
  TMailForward({
    this.id,
    this.localCopy,
    this.forwards,
  });

  factory TMailForward.fromJson(Map<String, dynamic> json) =>
      _$TMailForwardFromJson(json);

  Map<String, dynamic> toJson() => _$TMailForwardToJson(this);

  TMailForward copyWith({
    ForwardId? id,
    bool? localCopy,
    Set<String>? forwards,
  }) {
    return TMailForward(
      id: id ?? this.id,
      localCopy: localCopy ?? this.localCopy,
      forwards: forwards ?? this.forwards,
    );
  }
  @override
  List<Object?> get props => [
    id,
    localCopy,
    forwards,
  ];
}
