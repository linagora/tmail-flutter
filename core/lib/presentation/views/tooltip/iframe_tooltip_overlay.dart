import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class IframeTooltipOptions {
  final double tooltipBaseWidth;
  final double tooltipHeight;
  final double tooltipHorizontalMargin;
  final double tooltipMarginTop;
  final TextStyle? tooltipTextStyle;

  const IframeTooltipOptions({
    this.tooltipBaseWidth = 400,
    this.tooltipHeight = 28,
    this.tooltipHorizontalMargin = 12,
    this.tooltipMarginTop = 4,
    this.tooltipTextStyle,
  });
}

class IframeTooltipOverlay {
  OverlayEntry? _entry;

  final IframeTooltipOptions options;

  IframeTooltipOverlay({
    this.options = const IframeTooltipOptions(),
  });

  void show(
    BuildContext context,
    String url,
    Rect rect,
  ) {
    if (_entry != null) {
      hide();
      Future.microtask(() {
        if (context.mounted) {
          show(context, url, rect);
        }
      });
      return;
    }

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    Offset containerOffset = Offset.zero;
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      containerOffset = renderObject.localToGlobal(Offset.zero);
    }

    final adjustedRect = rect.shift(containerOffset);

    final viewportWidth = MediaQuery.sizeOf(context).width.toDouble();
    final viewportHeight = MediaQuery.sizeOf(context).height.toDouble();

    final tooltipWidth = viewportWidth < options.tooltipBaseWidth
        ? viewportWidth - options.tooltipHorizontalMargin * 2
        : options.tooltipBaseWidth;

    final showAbove = (adjustedRect.bottom +
            options.tooltipHeight +
            options.tooltipMarginTop) >
        viewportHeight;

    final tooltipTop = showAbove
        ? adjustedRect.top - options.tooltipHeight - options.tooltipMarginTop
        : adjustedRect.bottom + options.tooltipMarginTop;

    double tooltipLeft = adjustedRect.left;

    if (tooltipLeft + tooltipWidth > viewportWidth) {
      tooltipLeft =
          viewportWidth - tooltipWidth - options.tooltipHorizontalMargin;
    }

    if (tooltipLeft < options.tooltipHorizontalMargin) {
      tooltipLeft = options.tooltipHorizontalMargin;
    }

    _entry = OverlayEntry(
      builder: (_) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOut,
          builder: (context, opacity, child) {
            final slide = (showAbove ? -1 : 1) * (1 - opacity) * 8;

            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, slide),
                child: child,
              ),
            );
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: hide,
                ),
              ),
              PositionedDirectional(
                start: tooltipLeft,
                top: tooltipTop,
                child: PointerInterceptor(
                  child: Material(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: tooltipWidth,
                        minHeight: options.tooltipHeight,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Text(
                        url,
                        style: options.tooltipTextStyle ??
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlay.insert(_entry!);
  }

  void hide() {
    _entry?.remove();
    _entry = null;
  }
}
