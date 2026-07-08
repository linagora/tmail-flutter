/// Feature sub-robot: actions on the backend-positioned `X-TWP-Message`
/// warning banner shown in the opened email.
abstract class AbstractEmailTwpWarningRobot {
  Future<void> tapDismissWarning();
}
