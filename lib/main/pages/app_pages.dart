import 'dart:io';

import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart' deferred as composer;
import 'package:tmail_ui_user/features/contact/presentation/contact_bindings.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_bindings.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_view.dart' deferred as destination_picker;
import 'package:tmail_ui_user/features/email_recovery/presentation/email_recovery_bindings.dart';
import 'package:tmail_ui_user/features/home/presentation/home_bindings.dart';
import 'package:tmail_ui_user/features/home/presentation/home_view.dart';
import 'package:tmail_ui_user/features/contact/presentation/contact_view.dart' deferred as contact_view;
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_bindings.dart';
import 'package:tmail_ui_user/features/mailto/presentation/mailto_url_bindings.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_bindings.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_view.dart' deferred as rules_filter_creator;
import 'package:tmail_ui_user/features/login/presentation/login_bindings.dart';
import 'package:tmail_ui_user/features/login/presentation/login_view.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/login/presentation/login_view_web.dart' deferred as login;
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_view.dart' deferred as mailbox_creator;
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_view.dart' deferred as identity_creator;
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/mailbox_dashboard_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_view.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_view_web.dart' deferred as mailbox_dashboard;
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_view.dart' deferred as manage_account_dashboard;
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_bindings.dart';
import 'package:tmail_ui_user/features/starting_page/presentation/twake_welcome/twake_welcome_bindings.dart';
import 'package:tmail_ui_user/features/starting_page/presentation/twake_welcome/twake_welcome_view.dart';
import 'package:tmail_ui_user/features/unknown_route_page/unknown_route_page_view.dart';
import 'package:tmail_ui_user/main/pages/deferred_widget.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_view.dart' deferred as search_mailbox_view;
import 'package:tmail_ui_user/features/mailto/presentation/mailto_url_view.dart' deferred as mailto_url_view;
import 'package:tmail_ui_user/features/email_recovery/presentation/email_recovery_view.dart' deferred as email_recovery;

class AppPages {
  static final pages = [
    GetPage(
        name: AppRoutes.home,
        page: () => const HomeView(),
        binding: HomeBindings()),
    GetPage(
        name: AppRoutes.login,
        page: () => DeferredWidget(login.loadLibrary, () => login.LoginView()),
        binding: LoginBindings()),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DeferredWidget(
        mailbox_dashboard.loadLibrary,
        () => mailbox_dashboard.MailboxDashBoardView()),
      binding: MailboxDashBoardBindings()),
    GetPage(
      name: AppRoutes.dashboardWithParameter,
      page: () => DeferredWidget(
        mailbox_dashboard.loadLibrary,
        () => mailbox_dashboard.MailboxDashBoardView()
      ),
      binding: MailboxDashBoardBindings()
    ),
    GetPage(
      name: AppRoutes.mailtoURL,
      page: () => DeferredWidget(
        mailto_url_view.loadLibrary,
        () => mailto_url_view.MailtoUrlView()
      ),
      binding: MailtoUrlBindings()
    ),
    GetPage(
        name: AppRoutes.settings,
        page: () => DeferredWidget(
            manage_account_dashboard.loadLibrary,
            () => manage_account_dashboard.ManageAccountDashBoardView()),
        binding: ManageAccountDashBoardBindings()),
    GetPage(
      name: AppRoutes.contact,
      opaque: false,
      page: () => DeferredWidget(
        contact_view.loadLibrary,
        () => contact_view.ContactView()),
      binding: ContactBindings()),
    unknownRoutePage,
    if (PlatformInfo.isMobile)
      ...[
        GetPage(
          name: AppRoutes.twakeWelcome,
          page: () => const TwakeWelcomeView(),
          binding: TwakeWelcomeBindings()),
        GetPage(
            name: AppRoutes.composer,
            page: () => DeferredWidget(
                composer.loadLibrary,
                () => composer.ComposerView()),
            binding: ComposerBindings()),
        GetPage(
            name: AppRoutes.destinationPicker,
            opaque: false,
            page: () => DeferredWidget(
                destination_picker.loadLibrary,
                () => destination_picker.DestinationPickerView()),
            binding: DestinationPickerBindings()),
        GetPage(
            name: AppRoutes.mailboxCreator,
            opaque: false,
            page: () => DeferredWidget(
                mailbox_creator.loadLibrary,
                () => mailbox_creator.MailboxCreatorView()),
            binding: MailboxCreatorBindings()),
        GetPage(
            name: AppRoutes.rulesFilterCreator,
            opaque: false,
            page: () => DeferredWidget(
                rules_filter_creator.loadLibrary,
                () => rules_filter_creator.RuleFilterCreatorView()),
            binding: RulesFilterCreatorBindings()),
        GetPage(
          name: AppRoutes.searchMailbox,
          opaque: false,
          page: () => DeferredWidget(
            search_mailbox_view.loadLibrary,
            () => search_mailbox_view.SearchMailboxView()
          ),
          binding: SearchMailboxBindings()),
        GetPage(
          name: AppRoutes.identityCreator,
          opaque: Platform.isAndroid ? true : false,
          page: () => DeferredWidget(
            identity_creator.loadLibrary,
            () => identity_creator.IdentityCreatorView()
          ),
          binding: IdentityCreatorBindings()),
        GetPage(
          name: AppRoutes.emailRecovery,
          opaque: false,
          page: () => DeferredWidget(
            email_recovery.loadLibrary,
            () => email_recovery.EmailRecoveryView()
          ),
          binding: EmailRecoveryBindings()),
      ]
  ];

  static final unknownRoutePage = GetPage(
    name: AppRoutes.unknownRoutePage,
    page: () => UnknownRoutePageView(),
  );
}
