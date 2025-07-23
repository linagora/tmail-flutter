import 'dart:async';

import 'package:core/utils/platform_info.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide OverlayEntry;
import 'package:universal_html/html.dart' as html;

typedef OnRightMouseClickAction = void Function(RelativeRect position);
typedef OnDoubleClickAction = void Function(RelativeRect position);
typedef OnLongPressAction = void Function();

class SmartInteractionWidget extends StatefulWidget {
  final Widget child;
  final OnRightMouseClickAction onRightMouseClickAction;
  final OnDoubleClickAction onDoubleClickAction;
  final OnLongPressAction onLongPressAction;

  const SmartInteractionWidget({
    super.key,
    required this.child,
    required this.onRightMouseClickAction,
    required this.onDoubleClickAction,
    required this.onLongPressAction,
  });

  @override
  State<SmartInteractionWidget> createState() => _SmartInteractionWidgetState();
}

class _SmartInteractionWidgetState extends State<SmartInteractionWidget> {

  GlobalKey? _childKey;
  Offset? _lastPointerEventOffset;
  StreamSubscription<html.MouseEvent>? _contextMenuSubscription;

  @override
  void initState() {
    super.initState();
    if (PlatformInfo.isWeb) {
      _childKey = GlobalKey();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addWebContextMenuListener();
      });
    }
  }

  void _addWebContextMenuListener() {
    _contextMenuSubscription =
        html.document.onContextMenu.listen(_onContextMenuListener);
  }

  void _onContextMenuListener(html.MouseEvent event) {
    final renderBox =
        _childKey?.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = Offset(
      event.page.x.toDouble(),
      event.page.y.toDouble(),
    );
    final renderBoxPosition = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final rect = Rect.fromLTWH(
      renderBoxPosition.dx,
      renderBoxPosition.dy,
      size.width,
      size.height,
    );

    if (rect.contains(localPosition)) {
      event.preventDefault();

      if (!mounted) return;

      final relativeRect = _getRelativeRectFromOffset(context, localPosition);
      widget.onRightMouseClickAction(relativeRect);
    }
  }

  RelativeRect _getRelativeRectFromOffset(
    BuildContext context,
    Offset offset,
  ) {
    final widgetBox =
        _childKey?.currentContext?.findRenderObject() as RenderBox?;
    final overlayBox =
        Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;

    if (widgetBox == null || overlayBox == null) {
      final screenSize = MediaQuery.sizeOf(context);
      return RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        screenSize.width - offset.dx,
        screenSize.height - offset.dy,
      );
    } else {
      final targetPosition = widgetBox.localToGlobal(
        Offset.zero,
        ancestor: overlayBox,
      );
      final overlaySize = overlayBox.size;
      const topSpace = 4.0;

      return RelativeRect.fromLTRB(
        targetPosition.dx,
        targetPosition.dy + widgetBox.size.height + topSpace,
        overlaySize.width + targetPosition.dx,
        overlaySize.height - targetPosition.dy - widgetBox.size.height,
      );
    }
  }

  void _handleDoubleTap() {
    if (_lastPointerEventOffset != null) {
      final relativeRect = _getRelativeRectFromOffset(
        context,
        _lastPointerEventOffset!,
      );
      widget.onDoubleClickAction(relativeRect);
    }
  }

  void _handleLongPress() => widget.onLongPressAction();

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return Listener(
        key: _childKey,
        onPointerDown: (event) {
          if (event.kind == PointerDeviceKind.mouse ||
              event.kind == PointerDeviceKind.touch) {
            _lastPointerEventOffset = event.position;
          }
        },
        child: GestureDetector(
          onDoubleTap: _handleDoubleTap,
          child: widget.child,
        ),
      );
    } else {
      return GestureDetector(
        onLongPress: _handleLongPress,
        child: widget.child,
      );
    }
  }

  @override
  void dispose() {
    if (PlatformInfo.isWeb) {
      _lastPointerEventOffset = null;
      _contextMenuSubscription?.cancel();
    }
    super.dispose();
  }
}
