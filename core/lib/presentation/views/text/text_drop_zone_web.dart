import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/list_nullable_extensions.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:universal_html/html.dart' hide VoidCallback;

typedef OnSuperTextDrop = void Function(String value);

class TextDropZoneWeb extends StatefulWidget {
  const TextDropZoneWeb({
    super.key,
    required this.child,
    this.onHover,
    this.onLeave,
    this.onDrop,
  });

  final Widget child;
  final VoidCallback? onHover;
  final VoidCallback? onLeave;
  final OnSuperTextDrop? onDrop;

  @override
  State<TextDropZoneWeb> createState() => _TextDropZoneWebState();
}

class _TextDropZoneWebState extends State<TextDropZoneWeb> {
  bool _textIsDragging = false;
  StreamSubscription? _dragEnterSubscription;
  StreamSubscription? _dragOverSubscription;
  StreamSubscription? _dropSubscription;
  StreamSubscription? _dragLeaveSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dragEnterSubscription = window.onDragEnter.listen((event) {
        setState(() {
          _textIsDragging = event.dataTransfer.types?.validateFilesTransfer != true;
        });
      });
      _dragOverSubscription = window.onDragOver.listen((event) {
        setState(() {
          _textIsDragging = event.dataTransfer.types?.validateFilesTransfer != true;
        });
      });
      _dropSubscription = window.onDrop.listen((event) {
        setState(() {
          _textIsDragging = false;
        });
      });
      _dragLeaveSubscription = window.onDragLeave.listen((event) {
        setState(() {
          _textIsDragging = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _dragEnterSubscription?.cancel();
    _dragOverSubscription?.cancel();
    _dropSubscription?.cancel();
    _dragLeaveSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_textIsDragging) return widget.child;

    return DropRegion(
      formats: const [Formats.plainText],
      onDropOver: (dropOverEvent) {
        final dragItem = dropOverEvent.session.items.firstOrNull;
        if (dragItem == null || !dragItem.canProvide(Formats.plainText)) {
          return DropOperation.none;
        }

        widget.onHover?.call();
        
        return DropOperation.copy;
      },
      onDropLeave: (_) => widget.onLeave?.call(),
      onPerformDrop: (performDropEvent) async {
        final item = performDropEvent.session.items.firstOrNull;
        if (item == null) return;

        item.dataReader?.getValue<String>(
          Formats.plainText,
          (value) {
            log('TextDropZoneWeb::onPerformDrop:value = $value');
            if (value == null) return;
            widget.onDrop?.call(value);
          },
          onError: (error) {
            logError('TextDropZoneWeb::onPerformDrop:error: $error');
          }
        );
      },
      child: widget.child,
    );
  }
}