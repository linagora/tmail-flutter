import 'package:universal_html/js.dart' as js;

/// Whether the CanvasKit renderer is being used on web.
///
/// Always returns `false` on non-web.
bool get isRendererCanvasKit => js.context['flutterCanvasKit'] != null;