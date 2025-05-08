import 'package:core/presentation/views/html_viewer/model/event_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mouse_event_data.g.dart';

@JsonSerializable(explicitToJson: true)
class MouseEventData extends EventData {
  final double screenX;
  final double screenY;
  final double clientX;
  final double clientY;
  final int clickedMouseButtonType;
  final int pressedMouseButtonsMaskType;
  final bool isPointerDown;

  MouseEventData({
    required super.viewId,
    required super.command,
    required super.eventType,
    required this.screenX,
    required this.screenY,
    required this.clientX,
    required this.clientY,
    required this.clickedMouseButtonType,
    required this.pressedMouseButtonsMaskType,
    required this.isPointerDown,
    super.shouldBubble,
    super.isCancelable,
  });

  Map<String, dynamic> toJson() => _$MouseEventDataToJson(this);

  @override
  List<Object> get props => [
    ...super.props,
    screenX,
    screenY,
    clientX,
    clientY,
    clickedMouseButtonType,
    pressedMouseButtonsMaskType,
    isPointerDown,
  ];
}
