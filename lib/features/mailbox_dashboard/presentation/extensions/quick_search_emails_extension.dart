import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/quick_search_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

extension QuickSearchEmailsExtension on SearchController {
  Future<List<PresentationEmail>> quickSearchEmails({
    required Session session,
    required AccountId accountId,
    required String query,
    Set<MailboxId>? trashSpamMailboxIds,
  }) async {
    appProviderContainer
        .read(searchFilterProvider.notifier)
        .setText(query.asSearchFilterTextInput());
    final filter = appProviderContainer.read(searchFilterProvider);
    return await quickSearchEmailInteractor.execute(
      session,
      accountId,
      limit: UnsignedInt(5),
      sort: filter.sortOrderType.getSortOrder().toNullable(),
      // Suggestion and result screens share the committed SSOT: the `setText`
      // above commits this live query so both build from the same filter.
      filter: filter.mappingToEmailFilterCondition(
        trashSpamMailboxIds: trashSpamMailboxIds,
      ),
      properties: EmailUtils.getPropertiesForEmailGetMethod(session, accountId),
    ).then((result) => result.fold(
      (failure) => <PresentationEmail>[],
      (success) => success is QuickSearchEmailSuccess
        ? success.emailList
        : <PresentationEmail>[]
    ));
  }
}
