
import 'dart:convert';

import 'package:core/presentation/extensions/uri_extension.dart';
import 'package:jmap_dart_client/http/converter/state_converter.dart';
import 'package:jmap_dart_client/http/converter/user_name_converter.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/home/data/model/session_hive_obj.dart';
import 'package:tmail_ui_user/features/home/domain/converter/session_account_converter.dart';
import 'package:tmail_ui_user/features/home/domain/converter/session_capabilities_converter.dart';
import 'package:tmail_ui_user/features/home/domain/converter/session_primary_account_converter.dart';

extension SessionExtensions on Session {

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('capabilities', capabilities.map((key, value) =>  SessionCapabilitiesConverter().convertToMapEntry(key, value)));
    writeNotNull('accounts', accounts.map((key, value) => SessionAccountConverter().convertToMapEntry(key, value)));
    writeNotNull('primaryAccounts', primaryAccounts.map((key, value) => SessionPrimaryAccountConverter().convertToMapEntry(key, value)));
    writeNotNull('username', const UserNameConverter().toJson(username));
    writeNotNull('apiUrl', apiUrl.toString());
    writeNotNull('downloadUrl', downloadUrl.toString());
    writeNotNull('uploadUrl', uploadUrl.toString());
    writeNotNull('eventSourceUrl', eventSourceUrl.toString());
    writeNotNull('state', const StateConverter().toJson(state));

    return val;
  }

  SessionHiveObj toHiveObj() => SessionHiveObj(value: jsonEncode(toJson()));

  String getQualifiedApiUrl({String? baseUrl}) {
    if (baseUrl != null) {
      return apiUrl.toQualifiedUrl(baseUrl: Uri.parse(baseUrl)).toString();
    } else {
      return apiUrl.toString();
    }
  }
}