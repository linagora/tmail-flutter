import 'package:flutter/widgets.dart';
import 'package:universal_html/html.dart';

class HtmlIframeWidget extends StatelessWidget {
  const HtmlIframeWidget({
    super.key,
    this.onIframeCreated,
    this.width,
    this.height,
    this.borderRadius,
    this.src,
    this.srcdoc,
    this.sandbox,
  });

  final void Function(IFrameElement iframe)? onIframeCreated;
  final String? width, height, src, srcdoc;
  final double? borderRadius;

  /// Sandbox attribute value; null leaves the frame unsandboxed (trusted apps).
  final String? sandbox;

  /// Opaque origin: mail content cannot reach the app window, DOM or storage.
  static const String sandboxPolicy =
      'allow-scripts allow-popups allow-popups-to-escape-sandbox';

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      key: key,
      tagName: 'iframe',
      onElementCreated: (element) {
        final iframe = element as IFrameElement;
        if (sandbox != null) iframe.setAttribute('sandbox', sandbox!);
        onIframeCreated?.call(iframe);
        iframe
          ..width = width
          ..height = height
          ..style.border = 'none'
          ..style.overflow = 'hidden'
          ..style.width = '100%'
          ..style.height = '100%';

        if (borderRadius != null) {
          iframe.style.borderRadius = '${borderRadius}px';
        }

        if (src != null) {
          iframe.src = src;
        } else if (srcdoc != null) {
          iframe.srcdoc = srcdoc;
        }
      },
    );
  }
}
