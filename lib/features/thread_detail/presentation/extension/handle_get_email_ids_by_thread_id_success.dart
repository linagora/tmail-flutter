import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension HandleGetEmailIdsByThreadIdSuccess on ThreadDetailController {
  void handleGetEmailIdsByThreadIdSuccess(
    GetThreadByIdSuccess success,
  ) {
    final newEmailsInThreadDetail = <EmailId>[];
    if (success.emailIds.isNotEmpty) {
      if (success.updateCurrentThreadDetail) {
        newEmailsInThreadDetail.addAll(success
          .emailIds
          .where(
            (emailId) => !emailIdsPresentation.keys.contains(emailId),
          )
        );
        emailIdsPresentation
          ..removeWhere(
            (key, value) => !success.emailIds.contains(key),
          )
          ..addAll(Map.fromEntries(
            newEmailsInThreadDetail.map((emailId) => MapEntry(emailId, null)),
          ));
      } else {
        emailIdsPresentation.value = Map.fromEntries(success.emailIds.map(
          (emailId) => MapEntry(emailId, null),
        ));
      }
    } else if (mailboxDashBoardController.selectedEmail.value?.id != null) {
      emailIdsPresentation.value = {
        mailboxDashBoardController.selectedEmail.value!.id!: null,
      };
    }
  }
}