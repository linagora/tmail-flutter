import 'dart:async';

/// Keeps Flutter's own text selection and each email body iframe's native
/// selection mutually exclusive, so only one is ever active at a time.
class HtmlSelectionSyncBus {
  HtmlSelectionSyncBus._();

  static final HtmlSelectionSyncBus instance = HtmlSelectionSyncBus._();

  StreamController<void>? _flutterSelectionStartedController;
  StreamController<void>? _iframeSelectionStartedController;

  /// A selection started in the Flutter tree (e.g. the email subject).
  Stream<void> get flutterSelectionStarted =>
      (_flutterSelectionStartedController ??=
              StreamController<void>.broadcast())
          .stream;

  /// A selection started inside an email body iframe.
  Stream<void> get iframeSelectionStarted =>
      (_iframeSelectionStartedController ??=
              StreamController<void>.broadcast())
          .stream;

  void notifyFlutterSelectionStarted() {
    _flutterSelectionStartedController?.add(null);
  }

  void notifyIframeSelectionStarted() {
    _iframeSelectionStartedController?.add(null);
  }

  /// Releases both streams when the email view that owns them closes; the
  /// next view lazily recreates fresh ones on first subscribe.
  void dispose() {
    _flutterSelectionStartedController?.close();
    _iframeSelectionStartedController?.close();
    _flutterSelectionStartedController = null;
    _iframeSelectionStartedController = null;
  }
}
