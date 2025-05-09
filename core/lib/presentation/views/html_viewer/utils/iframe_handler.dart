import 'package:core/presentation/views/html_viewer/extension/pointer_event_extension.dart';
import 'package:core/presentation/views/html_viewer/model/mouse_event_data.dart';
import 'package:core/presentation/views/html_viewer/utils/event_constants.dart';
import 'package:universal_html/html.dart' as html;
import 'package:core/presentation/utils/shims/dart_ui.dart' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';

class IframeHandler {
  late html.IFrameElement iframeElement;
  late String viewId;
  bool isPointerDown = false;

  void initialize({
    required String id,
    required String content,
    required double width,
    required double height,
  }) {
    viewId = id;
    iframeElement = html.IFrameElement()
      ..width = width.toString()
      ..height = height.toString()
      ..srcdoc = content
      ..style.border = 'none'
      ..style.outline = 'none'
      ..style.overflow = 'hidden'
      ..style.width = '100%'
      ..style.height = '100%';

    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => iframeElement,
    );
  }

  void handlePointerEvent({
    required PointerEvent event,
    GlobalKey? htmlElementKey,
  }) {
    if (iframeElement.contentWindow == null) return;

    final RenderBox? htmlElementBox =
        htmlElementKey?.currentContext?.findRenderObject() as RenderBox?;
    if (htmlElementBox == null) return;

    final localPosition =
        event.position - htmlElementBox.localToGlobal(Offset.zero);

    String eventType = event.getEventType(isPointerDown);
    if (eventType.isEmpty) return;

    if (event is PointerDownEvent) {
      isPointerDown = true;
    } else if (event is PointerUpEvent) {
      isPointerDown = false;
    }

    sendMouseEventToIFrame(eventType, localPosition, event);
  }

  void sendMouseEventToIFrame(
    String eventType,
    Offset position,
    PointerEvent event,
  ) {
    final mouseEventData = MouseEventData(
      viewId: viewId,
      command: EventConstants.mouseEvent,
      eventType: eventType,
      screenX: event.position.dx,
      screenY: event.position.dy,
      clientX: position.dx,
      clientY: position.dy,
      clickedMouseButtonType: event is PointerDownEvent ? 0 : event.buttons - 1,
      pressedMouseButtonsMaskType: event.buttons,
      isPointerDown: event.down,
    );

    _sendEventToIFrame(jsonEncode(mouseEventData.toJson()));
  }

  void _sendEventToIFrame(String message) {
    iframeElement.contentWindow?.postMessage(message, '*');
  }
}
