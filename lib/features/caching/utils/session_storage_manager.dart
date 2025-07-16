
import 'package:collection/collection.dart';
import 'package:tmail_ui_user/features/caching/exceptions/local_storage_exception.dart';
import 'package:universal_html/html.dart' as html;

class SessionStorageManager {

  final html.Storage sessionStorage = html.window.sessionStorage;

  void save(String key, String value) {
    sessionStorage.addAll({key: value});
  }

  String get(String key) {
    final entry = sessionStorage
      .entries
      .firstWhereOrNull((entry) => entry.key == key);

    if (entry != null) {
      return entry.value;
    } else {
      throw NotFoundDataWithThisKeyException();
    }
  }

  void remove(String key) {
    if (sessionStorage.containsKey(key)) {
      sessionStorage.remove(key);
    }
  }
}