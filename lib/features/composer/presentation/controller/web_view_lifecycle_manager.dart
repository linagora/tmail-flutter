import 'package:core/utils/app_logger.dart';
import 'package:rich_text_composer/rich_text_composer.dart';

class WebViewLifecycleManager {
  final InAppWebViewController? controller;

  WebViewLifecycleManager(this.controller);

  Future<void> pause() async {
    if (controller == null) return;
    try {
      await controller!.pauseTimers();
      await controller!.pause();
    } catch (e) {
      logError('$runtimeType::pause:[WebViewLifecycleManager] pause error: $e');
    }
  }

  Future<void> resume() async {
    if (controller == null) return;
    try {
      await controller!.resume();
      await controller!.resumeTimers();
    } catch (e) {
      logError('$runtimeType::resume:[WebViewLifecycleManager] resume error: $e');
    }
  }
}
