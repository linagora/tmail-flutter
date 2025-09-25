import 'dart:async';
import 'dart:ui';

class ComposerTimer {
  static const int _delaySecondTime = 15;

  Timer? _timer;
  final Duration interval;
  final VoidCallback onTick;

  ComposerTimer({
    required this.onTick,
    this.interval = const Duration(seconds: _delaySecondTime),
  });

  void start() {
    stop();
    _timer = Timer.periodic(interval, (timer) {
      onTick();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isRunning => _timer?.isActive ?? false;
}
