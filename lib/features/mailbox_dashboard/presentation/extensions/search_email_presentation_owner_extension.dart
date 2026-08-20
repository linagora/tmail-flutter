import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/utils/search_email_presentation_owner_utils.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension SearchEmailPresentationOwnerExtension on MailboxDashBoardController {
  bool get isSearchEmailPresentationOwner {
    if (!searchController.isSearchEmailRunning) return false;

    if (!isSearchEmailPresentationLayoutOwner(
      context: currentContext,
      responsiveUtils: responsiveUtils,
    )) {
      return false;
    }

    return appProviderContainer
        .read(searchEmailPresentationProvider)
        .searchIsRunning;
  }
}
