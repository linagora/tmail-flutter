import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';

extension EmailIdExtension on EmailId {
  Map<Id, PatchObject> generateMapUpdateObjectEventAttendanceStatus(EventActionType eventActionType) {
    return {
      id: eventActionType.generateEventAttendanceStatusActionPath()
    };
  }
}