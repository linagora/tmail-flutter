import 'package:flutter/widgets.dart';
import 'package:universal_html/html.dart';

class HtmlIframeWidget extends StatelessWidget {
  const HtmlIframeWidget({
    super.key,
    this.onIframeCreated,
    this.width,
    this.height,
    this.src,
    this.srcdoc,
  });

  final void Function(IFrameElement iframe)? onIframeCreated;
  final String? width, height, src, srcdoc;

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      key: key,
      tagName: 'iframe',
      onElementCreated: (element) {
        final iframe = element as IFrameElement;
        onIframeCreated?.call(iframe);
        iframe
          ..width = width
          ..height = height
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;
        if (src != null) {
          iframe.src = src;
        } else if (srcdoc != null) {
          iframe.srcdoc = srcdoc;
        }
      },
    );
  }
}
