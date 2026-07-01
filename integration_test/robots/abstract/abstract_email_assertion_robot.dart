/// Assertion sub-robot for the email detail view. All methods are pure
/// (no side effects) and may be overridden per platform.
abstract class AbstractEmailAssertionRobot {
  Future<void> expectTwpWarningBannerVisible();
  Future<void> expectTwpWarningBannerNotVisible();
}
