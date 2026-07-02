import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/email_filter_condition_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/quick_search_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';

extension QuickSearchEmailsExtension on SearchController {
  Future<List<PresentationEmail>> quickSearchEmails({
    required Session session,
    required AccountId accountId,
    required String ownEmailAddress,
    required String query,
  }) async {
    currentSearchText = query;
    return await quickSearchEmailInteractor.execute(
      session,
      accountId,
      limit: UnsignedInt(5),
      sort: searchEmailFilter.value.sortOrderType
                  .getSortOrder()
                  .toNullable(),
      filter: _mappingToFilterOnSuggestionForm(
        currentUserEmail: ownEmailAddress,
        query: query,
      ),
      properties: EmailUtils.getPropertiesForEmailGetMethod(session, accountId),
    ).then((result) => result.fold(
      (failure) => <PresentationEmail>[],
      (success) => success is QuickSearchEmailSuccess
        ? success.emailList
        : <PresentationEmail>[]
    ));
  } 

  // Suggestion preview reads the committed SSOT (chips write it directly now), not a
  // staging list — the deferred-staging that caused #4421 is gone.
  Filter? _mappingToFilterOnSuggestionForm({required String query, required String currentUserEmail}) {
    log('SearchController::_mappingToFilterOnSuggestionForm()');
    final filter = searchEmailFilter.value;
    final filterCondition = EmailFilterCondition(
      text: query.isNotEmpty ? query : null,
      after: filter.startDate,
      before: filter.endDate,
      hasAttachment: filter.hasAttachment ? true : null,
      from: currentUserEmail.isNotEmpty && filter.from.contains(currentUserEmail)
        ? currentUserEmail
        : null,
      hasKeyword: filter.hasKeyword.contains(KeyWordIdentifier.emailFlagged.value)
        ? KeyWordIdentifier.emailFlagged.value
        : null,
    );

    return filterCondition.hasCondition
      ? filterCondition
      : null;
  }
}