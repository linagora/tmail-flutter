import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/read_actions.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/toggle_thread_detail_collape_expand.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleMarkMultipleEmailsReadSuccess on ThreadDetailController {
  void handleMarkMultipleEmailsReadSuccess(
    UIState success,
    ReadActions readActions,
    List<EmailId> emailIds,
  ) {
    mailboxDashBoardController.consumeState(Stream.value(Right(success)));
    if (readActions == ReadActions.markAsRead) return;

    if (emailsInThreadDetailInfo.length == 1) {
      closeThreadDetailAction(currentContext);
      return;
    }

    final expandedEmailId = currentExpandedEmailId.value;
    if (expandedEmailId == null) return;

    final expandedEmail = emailIdsPresentation[expandedEmailId];
    if (emailIds.contains(expandedEmailId) && expandedEmail != null) {
      toggleThreadDetailCollapeExpand(expandedEmail);
    }
  }
}