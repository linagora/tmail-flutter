
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/state/clean_and_get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/loading_more_status.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';

extension HandlePullToRefreshListEmailExtension on ThreadController {

  Future<void> onRefresh() async {
    log('HandlePullToRefreshListEmailExtension::onRefresh:Started');
    consumeState(Stream.value(Right(GetAllEmailLoading())));
    await Future.delayed(const Duration(milliseconds: 300)); // Create loading effect
    canLoadMore = false;
    loadingMoreStatus.value == LoadingMoreStatus.idle;
    getAllEmailAction();
  }

  Future<void> onCleanAndRefresh() async {
    log('HandlePullToRefreshListEmailExtension::onCleanAndRefresh:Started');
    resetToOriginalValue();
    cleanAndGetAllEmailAction();
  }

  Future<void> cleanAndGetAllEmailAction() async {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

    if (accountId == null || session == null) {
      consumeState(Stream.value(Left(CleanAndGetAllEmailFailure(NotFoundSessionException()))));
      return;
    }

    consumeState(cleanAndGetEmailsInMailboxInteractor.execute(
      session,
      accountId,
      limit: ThreadConstants.defaultLimit,
      sort: EmailSortOrderType.mostRecent.getSortOrder().toNullable(),
      emailFilter: EmailFilter(
        filter: getFilterCondition(mailboxIdSelected: selectedMailboxId),
        filterOption: mailboxDashBoardController.filterMessageOption.value,
        mailboxId: selectedMailboxId,
      ),
      propertiesCreated: EmailUtils.getPropertiesForEmailGetMethod(session, accountId),
      propertiesUpdated: EmailUtils.getPropertiesForEmailChangeMethod(
        session,
        accountId,
      ),
      getLatestChanges: true,
    ));
  }
}