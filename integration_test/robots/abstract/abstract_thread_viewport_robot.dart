abstract class AbstractThreadViewportRobot {
  /// Runs [body] in a window taller than one page of the thread list, then
  /// restores the previous window size.
  Future<void> withTallViewport(Future<void> Function() body);
}
