
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_all_local_email_draft_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/local_email_draft_extension.dart';

extension ReopenLocalEmailDraftExtension on MailboxDashBoardController {

  void handleGetAllLocalEmailDraftSuccess(GetAllLocalEmailDraftSuccess success) {
    final listPresentationLocalEmailDraft = success.listLocalEmailDraft
      .map((localEmailDraft) => localEmailDraft.toPresentation())
      .toList();
    final listLocalEmailDraftSortByIndex = listPresentationLocalEmailDraft
      ..sort((a, b) => (a.composerIndex ?? 0).compareTo(b.composerIndex ?? 0));
    log('ReopenLocalEmailDraftExtension::handleGetAllLocalEmailDraftSuccess:listLocalEmailDraftSortByIndex_length = ${listLocalEmailDraftSortByIndex.length}');
  }
}