import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
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
  Widget build(BuildContext context) {
    return PointerInterceptor(
    child: GestureDetector(
      onTap: onClose,
      behavior: HitTestBehavior.opaque,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 677),
          child: GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsetsGeometry.directional(end: 17),
                  child: TMailButtonWidget.fromIcon(
                    icon: ImagePaths().icClose,
                    iconColor: const Color(0xFF424244).withValues(alpha: 0.64),
                    padding: const EdgeInsets.all(12),
                    backgroundColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTapActionCallback: onClose,
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }
}
