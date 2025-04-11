
class TwakeAppManager {
  bool _hasComposer = false;
  bool _isSessionExpiresDialogOpened = false;

  void setHasComposer(bool value) => _hasComposer = value;

  bool get hasComposer => _hasComposer;

  void setSessionExpiresDialogDisplayState(bool value) => _isSessionExpiresDialogOpened = value;

  bool get isSessionExpiresDialogOpened => _isSessionExpiresDialogOpened;
}
