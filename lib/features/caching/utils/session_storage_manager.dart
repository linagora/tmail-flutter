
import 'package:collection/collection.dart';
import 'package:tmail_ui_user/features/caching/exceptions/local_storage_exception.dart';
import 'package:universal_html/html.dart' as html;

class SessionStorageManager {

  final html.Storage sessionStorage = html.window.sessionStorage;

  Future<void> save(String key, String value) async {
    return sessionStorage.addAll({key: value});
  }

  Future<String> get(String key) async {
    final entry = sessionStorage
      .entries
      .firstWhereOrNull((entry) => entry.key == key);

    if (entry != null) {
      return entry.value;
    } else {
      throw NotFoundDataWithThisKeyException();
    }
  }

  Future<void> remove(String key) async {
    if (sessionStorage.containsKey(key)) {
      sessionStorage.remove(key);
    }
  }
}