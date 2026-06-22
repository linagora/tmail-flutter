import 'package:flutter/widgets.dart';
import 'package:universal_html/html.dart';

class HtmlIframeWidget extends StatelessWidget {
  const HtmlIframeWidget({super.key, this.onIframeCreated});

  final void Function(IFrameElement iframe)? onIframeCreated;

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      key: key,
      tagName: 'iframe',
      onElementCreated: (element) {
        final iframe = element as IFrameElement;
        onIframeCreated?.call(iframe);
        iframe
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;
      },
    );
  }
}
