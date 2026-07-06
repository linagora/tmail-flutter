import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/quick_search_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

extension QuickSearchEmailsExtension on SearchController {
  Future<List<PresentationEmail>> quickSearchEmails({
    required Session session,
    required AccountId accountId,
    required String query,
    Set<MailboxId>? trashSpamMailboxIds,
  }) async {
    currentSearchText = query;
    final filter = searchEmailFilter.value;
    return await quickSearchEmailInteractor.execute(
      session,
      accountId,
      limit: UnsignedInt(5),
      sort: filter.sortOrderType.getSortOrder().toNullable(),
      // Suggestion and result screens must share one filter set. Build the query
      // from the committed SSOT via the same `mappingToEmailFilterCondition` the
      // result screen uses, only layering the live query text on top (#SSOT-3).
      filter: filter
          .copyWith(
            textOption: query.trim().isNotEmpty
                ? Some(SearchQuery(query))
                : const None(),
          )
          .mappingToEmailFilterCondition(trashSpamMailboxIds: trashSpamMailboxIds),
      properties: EmailUtils.getPropertiesForEmailGetMethod(session, accountId),
    ).then((result) => result.fold(
      (failure) => <PresentationEmail>[],
      (success) => success is QuickSearchEmailSuccess
        ? success.emailList
        : <PresentationEmail>[]
    ));
  }
}
