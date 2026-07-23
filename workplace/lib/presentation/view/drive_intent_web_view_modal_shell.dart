import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

typedef DriveMessageHandler = void Function(String raw, String? origin);
typedef OnRegisterExternalHandler = void Function(DriveMessageHandler handler);

class DriveIntentWebViewModalShell extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;
  final EdgeInsets insetPadding;
  final ShapeBorder? shape;
  final BoxConstraints? constraints;
  final bool haveCloseButton;
  final AlignmentGeometry? alignment;

  const DriveIntentWebViewModalShell({
    super.key,
    required this.child,
    required this.onClose,
    this.insetPadding = const EdgeInsets.all(0),
    this.shape,
    this.constraints,
    this.haveCloseButton = true,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: GestureDetector(
        onTap: onClose,
        behavior: HitTestBehavior.opaque,
        child: Dialog(
          backgroundColor: Colors.white,
          insetPadding: insetPadding,
          shape: shape,
          constraints: constraints,
          alignment: alignment,
          child: GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (haveCloseButton) ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsetsGeometry.directional(end: 17),
                    child: TMailButtonWidget.fromIcon(
                      icon: ImagePaths().icClose,
                      iconColor: const Color(
                        0xFF424244,
                      ).withValues(alpha: 0.64),
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTapActionCallback: onClose,
                    ),
                  ),
                ],
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
