import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:tmail_ui_user/main/utils/cozy_contact.dart';
import 'package:tmail_ui_user/main/utils/cozy_js_interop.dart';
import 'package:linagora_design_flutter/cozy_config_manager/cozy_config_manager.dart';
import 'package:universal_html/js_util.dart';

class CozyConfig {
  static final CozyConfig _instance = CozyConfig._internal();

  factory CozyConfig() {
    return _instance;
  }

  CozyConfig._internal();

  final manager = CozyConfigManager();

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
        JSString() => flag.toDart,
        JSNumber() => flag.toDartDouble,
        JSObject() => stringify(flag),
        _ => null,
      };
    } catch (e) {
      print('Error getting cozy feature flag: $e');
      return null;
    }
  }
}
