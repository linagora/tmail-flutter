
import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_detail_info.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

/// Inputs for per-row mailbox, selection, and web-route sync.
class PresentationEmailSyncContext {
  const PresentationEmailSyncContext({
    required this.mapMailboxById,
    this.selectedMailbox,
    this.searchQuery,
    this.isSearchEmailRunning = false,
  });

  final Map<MailboxId, PresentationMailbox> mapMailboxById;
  final PresentationMailbox? selectedMailbox;
  final SearchQuery? searchQuery;
  final bool isSearchEmailRunning;
}

extension ListPresentationEmailExtensions on List<PresentationEmail> {

  /// Converts the executor's full search result into display-ready rows.
  /// Keeps current selection by combining with [previousList].
  List<PresentationEmail> toSyncedSearchResults({
    required PresentationEmailSyncContext context,
    required List<PresentationEmail> previousList,
  }) {
    return map((email) => email.toSearchPresentationEmail(context.mapMailboxById))
        .toList()
        .combine(previousList)
        .syncPresentationEmail(
          mapMailboxById: context.mapMailboxById,
          selectedMailbox: context.selectedMailbox,
          searchQuery: context.searchQuery,
          isSearchEmailRunning: context.isSearchEmailRunning,
        );
  }

  List<PresentationEmail> syncPresentationEmail({
    required Map<MailboxId, PresentationMailbox> mapMailboxById,
    PresentationMailbox? selectedMailbox,
    bool isSearchEmailRunning = false,
    SearchQuery? searchQuery
  }) {
    final newEmailList = map((presentationEmail) {
      final routeUri = _generateNavigationRoute(
        currentEmail: presentationEmail,
        selectedMailbox: selectedMailbox,
        isSearchEmailRunning: isSearchEmailRunning,
        searchQuery: searchQuery
      );
      final mailboxContain = presentationEmail.findMailboxContain(mapMailboxById);

      return presentationEmail.syncPresentationEmail(
        mailboxContain: mailboxContain,
        routeWeb: routeUri
      );
    }).toList();

    return newEmailList;
  }

  Uri? _generateNavigationRoute({
    required PresentationEmail currentEmail,
    PresentationMailbox? selectedMailbox,
    bool isSearchEmailRunning = false,
    SearchQuery? searchQuery,
  }) {
    if (PlatformInfo.isWeb) {
      final route = RouteUtils.createUrlWebLocationBar(
        AppRoutes.dashboard,
        router: NavigationRouter(
          emailId: currentEmail.id,
          mailboxId: isSearchEmailRunning
              ? null
              : selectedMailbox?.browserRouteMailboxId,
          labelId: selectedMailbox?.labelId,
          searchQuery: isSearchEmailRunning ? searchQuery : null,
          dashboardType: isSearchEmailRunning ? DashboardType.search : DashboardType.normal
        )
      );
      return route;
    } else {
      return null;
    }
  }

  List<EmailInThreadDetailInfo> toEmailsInThreadDetailInfo({
    required MailboxId? sentMailboxId,
    required String? ownEmailAddress,
  }) {
    return map(
      (email) => EmailInThreadDetailInfo(
        emailId: email.id!,
        keywords: email.keywords,
        mailboxIds: email.mailboxIds,
        isValidToDisplay: sentMailboxId == null || ownEmailAddress == null
            ? true
            : email.toEmail().checkEmailValidForThreadDetail(
                  sentMailboxId,
                  ownEmailAddress,
                ),
      ),
    ).toList();
  }
}