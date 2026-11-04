import 'dart:async';

typedef SwitchLoadingDialogVisibilityChanged = void Function(bool visible);

/// Delays the switch loading dialog and keeps it up for a minimum time.
class SwitchLoadingDialogTiming {
  static const showDelay = Duration(milliseconds: 300);
  static const minVisible = Duration(milliseconds: 500);

  final SwitchLoadingDialogVisibilityChanged onVisibilityChanged;

  Timer? _showTimer;
  Timer? _minVisibleTimer;
  bool _switchRunning = false;
  bool _visible = false;
  bool _minVisibleElapsed = false;

  SwitchLoadingDialogTiming({required this.onVisibilityChanged});

  bool get isVisible => _visible;

  void switchStarted() {
    _switchRunning = true;
    if (_visible || _showTimer != null) return;
    _showTimer = Timer(showDelay, _show);
  }

  void switchEnded() {
    _switchRunning = false;
    _showTimer?.cancel();
    _showTimer = null;
    if (!_visible) return;
    if (_minVisibleElapsed) {
      _hide();
    }
  }

  void dispose() {
    _showTimer?.cancel();
    _minVisibleTimer?.cancel();
    _showTimer = null;
    _minVisibleTimer = null;
  }

  void _show() {
    _showTimer = null;
    if (!_switchRunning || _visible) return;
    _visible = true;
    _minVisibleElapsed = false;
    onVisibilityChanged(true);
    _minVisibleTimer = Timer(minVisible, _onMinVisibleElapsed);
  }

  void _onMinVisibleElapsed() {
    _minVisibleTimer = null;
    _minVisibleElapsed = true;
    if (!_switchRunning) _hide();
  }

  void _hide() {
    if (_switchRunning || !_visible) return;
    _minVisibleTimer?.cancel();
    _minVisibleTimer = null;
    _visible = false;
    _minVisibleElapsed = false;
    onVisibilityChanged(false);
  }
}
