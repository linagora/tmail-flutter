import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class DriveIntentWebViewModalShell extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;
  // Tap outside the dialog card (the backdrop). Defaults to [onClose], but
  // must stay disabled while loading — unlike the close button, which should
  // always work — so callers pass a guarded callback here when needed.
  final VoidCallback? onBarrierTap;
  final EdgeInsets insetPadding;
  final ShapeBorder? shape;
  final BoxConstraints? constraints;
  final bool haveCloseButton;
  final AlignmentGeometry? alignment;
  final Widget Function(TMailButtonWidget closeButton)? loadingWidget;
  final String closeIconPath;

  const DriveIntentWebViewModalShell({
    super.key,
    required this.child,
    required this.onClose,
    required this.closeIconPath,
    this.onBarrierTap,
    this.insetPadding = const EdgeInsets.all(0),
    this.shape,
    this.constraints,
    this.haveCloseButton = true,
    this.alignment,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final closeButton = TMailButtonWidget.fromIcon(
      icon: closeIconPath,
      width: 40,
      height: 40,
      iconSize: 24,
      iconColor: const Color(0xFF424244).withValues(alpha: 0.64),
      padding: const EdgeInsets.all(8),
      backgroundColor: Colors.transparent,
      hoverColor: const Color(0x14424244),
      onTapActionCallback: onClose,
    );
    return GestureDetector(
      onTap: onBarrierTap ?? onClose,
      behavior: HitTestBehavior.opaque,
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: insetPadding,
        shape: shape,
        constraints: constraints,
        alignment: alignment,
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (haveCloseButton)
                    Padding(
                      padding: const EdgeInsetsGeometry.directional(end: 17),
                      child: closeButton,
                    ),
                  // Keep the iframe mounted across responsive changes (#4738).
                  Expanded(
                    key: const ValueKey('drive-shell-content'),
                    child: child,
                  ),
                ],
              ),
              if (loadingWidget != null)
                Positioned.fill(
                  child: PointerInterceptor(
                    child: loadingWidget!(closeButton),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
