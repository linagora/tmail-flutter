import 'package:core/presentation/views/html_viewer/utils/event_constants.dart';
import 'package:flutter/gestures.dart';

extension PointerEventExtension on PointerEvent {
  String getEventType(bool isPointerDown) {
    if (this is PointerDownEvent) return EventConstants.mouseDown;
    if (this is PointerUpEvent) return EventConstants.mouseUp;
    if (this is PointerHoverEvent) return EventConstants.mouseOver;
    if (this is PointerMoveEvent) {
      return isPointerDown
          ? EventConstants.mouseMove
          : EventConstants.mouseOver;
    }
    return '';
  }
}
