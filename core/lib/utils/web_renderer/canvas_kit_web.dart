import 'dart:js' as js;

/// Whether the CanvasKit renderer is being used on web.
///
/// Always returns `false` on non-web.
bool get isRendererCanvasKit => js.context['flutterCanvasKit'] != null;