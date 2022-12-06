
import 'package:core/utils/build_utils.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

extension ListPresentationEmailExtensions on List<PresentationEmail> {

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
    if (BuildUtils.isWeb) {
      final route = RouteUtils.generateRouteBrowser(
        AppRoutes.dashboard,
        NavigationRouter(
          emailId: currentEmail.id,
          mailboxId: selectedMailbox?.id,
          searchQuery: isSearchEmailRunning ? searchQuery : null,
          dashboardType: isSearchEmailRunning ? DashboardType.search : DashboardType.normal
        )
      );
      return route;
    } else {
      return null;
    }
  }
}