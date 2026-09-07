import 'dart:async';

/// Keeps Flutter's own text selection and each email body iframe's native
/// selection mutually exclusive, so only one is ever active at a time.
class HtmlSelectionSyncBus {
  HtmlSelectionSyncBus._();

  static final HtmlSelectionSyncBus instance = HtmlSelectionSyncBus._();

  final StreamController<void> _flutterSelectionStartedController =
      StreamController<void>.broadcast();
  final StreamController<void> _iframeSelectionStartedController =
      StreamController<void>.broadcast();

  /// A selection started in the Flutter tree (e.g. the email subject).
  Stream<void> get flutterSelectionStarted =>
      _flutterSelectionStartedController.stream;

  /// A selection started inside an email body iframe.
  Stream<void> get iframeSelectionStarted =>
      _iframeSelectionStartedController.stream;

  void notifyFlutterSelectionStarted() {
    _flutterSelectionStartedController.add(null);
  }

  void notifyIframeSelectionStarted() {
    _iframeSelectionStartedController.add(null);
  }
}
