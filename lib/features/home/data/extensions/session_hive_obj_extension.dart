
import 'dart:convert';

import 'package:jmap_dart_client/http/converter/capabilities_converter.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/home/data/model/session_hive_obj.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';

extension SessionHiveObjExtension on SessionHiveObj {
  Session toSession() => Session.fromJson(
    jsonDecode(value),
    converter: CapabilitiesConverter.defaultConverter
      ..addConverters(SessionExtensions.customMapCapabilitiesConverter),
  );
}