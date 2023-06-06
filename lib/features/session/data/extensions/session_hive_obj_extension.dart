
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/session/data/model/session_hive_obj.dart';

extension SessionHiveObjExtension on SessionHiveObj {
  Session toSession() => Session.fromJson(values);
}