import 'package:equatable/equatable.dart';

abstract class EventData with EquatableMixin {
  final String viewId;
  final String command;
  final String eventType;
  final bool shouldBubble;
  final bool isCancelable;

  EventData({
    required this.viewId,
    required this.command,
    required this.eventType,
    this.shouldBubble = true,
    this.isCancelable = true,
  });

  @override
  List<Object> get props => [
    viewId,
    command,
    eventType,
    shouldBubble,
    isCancelable,
  ];
}
