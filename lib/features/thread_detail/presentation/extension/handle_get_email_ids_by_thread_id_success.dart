// ignore_for_file: invalid_use_of_protected_member

import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension HandleGetEmailIdsByThreadIdSuccess on ThreadDetailController {
  void handleGetEmailIdsByThreadIdSuccess(
    GetThreadByIdSuccess success,
  ) {
    final currentThreadId = mailboxDashBoardController.selectedEmail.value?.threadId;
    if (success.emailIds.isEmpty || success.threadId != currentThreadId) {
      return;
    }

    final allEmailIds = success.emailIds;
    final allEmailsInThreadDetailInfo = success.emailsInThreadDetailInfo;
    if (success.updateCurrentThreadDetail) {
      final newEmailIds = allEmailIds.where(
        (emailId) => !emailIdsPresentation.keys.contains(emailId),
      );
      final newEmailsInThreadDetailInfo = allEmailsInThreadDetailInfo.where(
        (email) => !emailsInThreadDetailInfo.contains(email),
      );
      emailIdsPresentation
        ..removeWhere((key, _) => !allEmailIds.contains(key))
        ..addEntries(
          newEmailIds.map((emailId) => MapEntry(emailId, null)),
        );
      emailsInThreadDetailInfo
        ..removeWhere((e) => !allEmailsInThreadDetailInfo.contains(e))
        ..addAll(newEmailsInThreadDetailInfo);
      return;
    }

    final selectedEmail = mailboxDashBoardController.selectedEmail.value;
    final selectedEmailId = selectedEmail?.id;
    final originalMap = Map.from(emailIdsPresentation.value);
    _assignNewThreadEmailIdsWithoutRebuildingTheUI(
      allEmailIds,
      selectedEmailId,
      originalMap,
      selectedEmail,
    );
    if ((isThreadDetailEnabled && success is! PreloadEmailIdsInThreadSuccess) ||
        (!isThreadDetailEnabled && success is PreloadEmailIdsInThreadSuccess)) {
      emailsInThreadDetailInfo.value = allEmailsInThreadDetailInfo;
    }
  }

  void _assignNewThreadEmailIdsWithoutRebuildingTheUI(
    List<EmailId> allEmailIds,
    EmailId? selectedEmailId,
    Map<dynamic, dynamic> originalMap,
    PresentationEmail? selectedEmail,
  ) {
    emailIdsPresentation.value..clear()..addAll({
      for (final id in allEmailIds)
        id: id == selectedEmailId
            ? originalMap[id] ?? selectedEmail
            : null,
    });
  }
}