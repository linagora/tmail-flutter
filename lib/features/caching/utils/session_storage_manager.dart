
import 'package:collection/collection.dart';
import 'package:tmail_ui_user/features/caching/exceptions/local_storage_exception.dart';
import 'package:universal_html/html.dart' as html;

class SessionStorageManager {

  void save(String key, String value) {
    html.window.sessionStorage.addAll({key: value});
  }

  String get(String key) {
    final entry = html.window.sessionStorage
      .entries
      .firstWhereOrNull((entry) => entry.key == key);

    if (entry != null) {
      return entry.value;
    } else {
      throw NotFoundDataWithThisKeyException();
    }
  }

  void remove(String key) {
    html.window.sessionStorage.remove(key);
  }
}