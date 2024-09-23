import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_socket_ticket.g.dart';

@JsonSerializable(includeIfNull: false)
class WebSocketTicket with EquatableMixin {
  final String? ticket;
  final String? clientAddress;
  final DateTime? generatedOn;
  final DateTime? validUntil;

  WebSocketTicket({
    required this.ticket,
    required this.clientAddress,
    required this.generatedOn,
    required this.validUntil,
  });

  factory WebSocketTicket.fromJson(Map<String, dynamic> json) => _$WebSocketTicketFromJson(json);
  Map<String, dynamic> toJson() => _$WebSocketTicketToJson(this);

  @override
  List<Object?> get props => [
    ticket,
    clientAddress,
    generatedOn,
    validUntil];
}