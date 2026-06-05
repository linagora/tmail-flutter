import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

typedef DriveMessageHandler = void Function(String raw, String? origin);
typedef OnRegisterExternalHandler = void Function(DriveMessageHandler handler);

class DriveIntentWebViewModalShell extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;

  const DriveIntentWebViewModalShell({
    super.key,
    required this.child,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) => PointerInterceptor(
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          child: Column(
            children: [
              _ModalHeader(onClose: onClose),
              Expanded(child: child),
            ],
          ),
        ),
      );
}

class _ModalHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _ModalHeader({required this.onClose});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      );
}
