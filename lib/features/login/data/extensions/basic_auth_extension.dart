import 'dart:convert';

import 'package:model/account/basic_auth.dart';
import 'package:tmail_ui_user/features/login/data/model/basic_auth_cache.dart';

extension BasicAuthExtension on BasicAuth {
  BasicAuthCache toBasicAuthCache() {
    return BasicAuthCache(userName.value, password.value);
  }

  String get authenticationHeader => 'Basic ${base64Encode(utf8.encode('${userName.value}:${password.value}'))}';
}