import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:tmail_ui_user/main/utils/cozy_contact.dart';
import 'package:tmail_ui_user/main/utils/cozy_js_interop.dart';
import 'package:universal_html/js_util.dart';

class CozyConfigManager {
  static final CozyConfigManager _instance = CozyConfigManager._internal();
  bool? _isInsideCozy;

  factory CozyConfigManager() {
    return _instance;
  }

  CozyConfigManager._internal();

  bool get isInsideCozy {
    _isInsideCozy = isInsideCozyJs() ?? false;
    print('isInsideCozy: $_isInsideCozy'); 
    return _isInsideCozy!;
  }

  void initialize() {
    try {
      setupBridgeJs();
      startHistorySyncingJs();
    } catch (e) {
      print('Error initializing Cozy bridge: $e');
    }
  }

  Future<List<CozyContact>> getCozyContacts() async {
    try {
      final contacts = await promiseToFuture(getContactsJs());
      return (contacts as JSArray<JSObject>)
        .toDart
        .map((contact) => CozyContact.fromJson(jsonDecode(stringify(contact))))
        .toList();
    } catch (e) {
      print('Error getting cozy contacts: $e');
      return [];
    }
  }

  Future<dynamic> getCozyFeatureFlag(String flagName) async {
    try {
      final flag = await promiseToFuture(getFlagJs(flagName));
      return switch (flag) {
        JSBoolean() => flag.toDart,
        JSString() => flag.toDart == 'true',
        _ => false,
      };
    } catch (e) {
      print('Error getting cozy feature flag: $e');
      return null;
    }
  }
}
