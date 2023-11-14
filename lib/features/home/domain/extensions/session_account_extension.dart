
import 'package:jmap_dart_client/http/converter/account_name_converter.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:tmail_ui_user/features/home/domain/converter/session_capabilities_converter.dart';

extension SessionAccountExtension on Account {

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('name', const AccountNameConverter().toJson(name));
    writeNotNull('isPersonal', isPersonal);
    writeNotNull('isReadOnly', isReadOnly);
    writeNotNull('accountCapabilities', accountCapabilities.map((key, value) =>  SessionCapabilitiesConverter().convertToMapEntry(key, value)));

    return val;
  }
}