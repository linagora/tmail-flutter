
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_composer_cache_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';

extension ReopenLocalEmailDraftExtension on MailboxDashBoardController {

  void handleGetLocalEmailDraftSuccess(GetLocalEmailDraftSuccess success) {
    removeAllLocalEmailDraft();

    final listLocalEmailDraftSortByIndex = success.listLocalEmailDraft
      ..sort((a, b) => (a.composerIndex ?? 0).compareTo(b.composerIndex ?? 0));

    final listArguments = listLocalEmailDraftSortByIndex
      .map((composerCache) => ComposerArguments.fromSessionStorageBrowser(composerCache))
      .toList();

    openListComposer(listArguments);
  }
}