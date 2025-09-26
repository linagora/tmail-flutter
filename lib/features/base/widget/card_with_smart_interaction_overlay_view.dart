import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/widget/smart_interaction_widget.dart';

class CardWithSmartInteractionOverlayView extends StatefulWidget {
  final Widget child;
  final double overlayWidth;
  final Widget Function(VoidCallback onClose) menuBuilder;
  final VoidCallback? onClearFocusAction;

  const CardWithSmartInteractionOverlayView({
    super.key,
    required this.child,
    required this.menuBuilder,
    this.overlayWidth = 361,
    this.onClearFocusAction,
  });

  @override
  State<CardWithSmartInteractionOverlayView> createState() => _CardWithSmartInteractionOverlayViewState();
}

class _CardWithSmartInteractionOverlayViewState
    extends State<CardWithSmartInteractionOverlayView>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late AnimationController _controller;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  void _showPopup() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: PointerInterceptor(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removePopup,
              ),
            ),
          ),
          Positioned(
            width: widget.overlayWidth,
            child: CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(
                0,
                PlatformInfo.isWeb ? 40 : 50,
              ),
              showWhenUnlinked: false,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeOut,
                ),
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOutBack,
                  ),
                  alignment: Alignment.topLeft,
                  child: widget.menuBuilder(_removePopup),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.maybeOf(context)?.insert(_overlayEntry!);
    _controller.forward();
  }

  Future<void> _removePopup() async {
    if (_overlayEntry == null) return;

    if (!_isDisposed && _controller.isAnimating == false) {
      await _controller.reverse();
    }

    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: SmartInteractionWidget(
        onRightMouseClickAction: ({RelativeRect? position}) => _togglePopup(),
        onDoubleClickAction: ({RelativeRect? position}) => _togglePopup(),
        onTapAction: _togglePopup,
        child: widget.child,
      ),
    );
  }

  void _togglePopup() {
    FocusManager.instance.primaryFocus?.unfocus();

    widget.onClearFocusAction?.call();
    
    if (_overlayEntry == null) {
      _showPopup();
    } else {
      _removePopup();
    }
  }
}
