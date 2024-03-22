
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'broadcast_message_event_data.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class BroadcastMessageEventData with EquatableMixin {

  final String? messageId;
  final Map<String, dynamic>? data;

  BroadcastMessageEventData(this.messageId, this.data);

  factory BroadcastMessageEventData.fromJson(Map<String, dynamic> json) => _$BroadcastMessageEventDataFromJson(json);

  Map<String, dynamic> toJson() => _$BroadcastMessageEventDataToJson(this);

  @override
  List<Object?> get props => [messageId, data];
}