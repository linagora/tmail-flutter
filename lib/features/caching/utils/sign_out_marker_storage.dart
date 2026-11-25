import 'package:universal_html/html.dart' as html;

/// Direct, single-key access to the sign-out marker in localStorage.
/// Reads are O(1); the storage managers iterate every entry.
class SignOutMarkerStorage {
  static const String markerKey = 'basicAuthSignOutMarker';

  String? read() => html.window.localStorage[markerKey];

  void write(String marker) => html.window.localStorage[markerKey] = marker;

  void remove() => html.window.localStorage.remove(markerKey);
}
