import 'package:core/utils/platform_info.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension SearchEmailPresentationOwnerExtension on MailboxDashBoardController {
  bool get isSearchEmailPresentationOwner {
    if (!searchController.isSearchEmailRunning) return false;

    if (PlatformInfo.isWeb) {
      final context = currentContext;
      if (context != null && responsiveUtils.isWebDesktop(context)) {
        return false;
      }
    }

    return appProviderContainer
        .read(searchEmailPresentationProvider)
        .searchIsRunning;
  }
}
