import 'dart:async';

typedef SwitchLoadingDialogVisibilityChanged = void Function(bool visible);

/// Delays the switch loading dialog and keeps it up for a minimum time.
class SwitchLoadingDialogTiming {
  /// Override with `--dart-define=ACCOUNT_SWITCH_LOADING_SHOW_DELAY_MS=0` in
  /// Patrol so a fast local switch still paints the dialog long enough to assert.
  static const showDelay = Duration(
    milliseconds: int.fromEnvironment(
      'ACCOUNT_SWITCH_LOADING_SHOW_DELAY_MS',
      defaultValue: 300,
    ),
  );
  static const minVisible = Duration(milliseconds: 500);

  final SwitchLoadingDialogVisibilityChanged onVisibilityChanged;
  final Duration _showDelay;

  Timer? _showTimer;
  Timer? _minVisibleTimer;
  bool _switchRunning = false;
  bool _visible = false;
  bool _minVisibleElapsed = false;
  bool _zeroDelayShowScheduled = false;

  SwitchLoadingDialogTiming({
    required this.onVisibilityChanged,
    Duration? showDelay,
  }) : _showDelay = showDelay ?? SwitchLoadingDialogTiming.showDelay;

  bool get isVisible => _visible;

  bool get _showAlreadyPending =>
      _visible || _showTimer != null || _zeroDelayShowScheduled;

  void switchStarted() {
    _switchRunning = true;
    if (_showAlreadyPending) return;
    // Duration.zero: do not use Timer(Duration.zero) — that macrotask can be
    // cancelled by switchEnded when load finishes in microtasks (Patrol with
    // dart-define show delay 0). A microtask still runs after the menu-tap
    // stack (safe for Navigator.push) and before I/O macrotasks, and
    // switchEnded must not cancel it.
    if (_showDelay == Duration.zero) {
      _zeroDelayShowScheduled = true;
      scheduleMicrotask(_showAfterZeroDelay);
      return;
    }
    _showTimer = Timer(_showDelay, _show);
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
    _zeroDelayShowScheduled = false;
  }

  void _showAfterZeroDelay() {
    // dispose() clears this flag to drop a queued microtask safely.
    if (!_zeroDelayShowScheduled) return;
    _zeroDelayShowScheduled = false;
    if (_visible) return;
    // Paint even if the switch already ended — hold for minVisible.
    _visible = true;
    _minVisibleElapsed = false;
    onVisibilityChanged(true);
    _minVisibleTimer = Timer(minVisible, _onMinVisibleElapsed);
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
