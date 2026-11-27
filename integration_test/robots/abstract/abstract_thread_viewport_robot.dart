typedef ViewportBody = Future<void> Function();

abstract class AbstractThreadViewportRobot {
  /// Runs [body] in a window taller than one page of the thread list, then
  /// restores the previous window size.
  Future<void> withTallViewport(ViewportBody body);

  /// Runs [body] in a window narrower than the desktop layout, then restores
  /// the previous window size.
  Future<void> withCompactViewport(ViewportBody body);
}
