import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart' deferred as composer;
import 'package:tmail_ui_user/features/contact/presentation/contact_bindings.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_bindings.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_view.dart' deferred as destination_picker;
import 'package:tmail_ui_user/features/home/presentation/home_bindings.dart';
import 'package:tmail_ui_user/features/home/presentation/home_view.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_bindings.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_view.dart' deferred as identity_creator;
import 'package:tmail_ui_user/features/emails_forward_creator/presentation/emails_forward_creator_binding.dart';
import 'package:tmail_ui_user/features/emails_forward_creator/presentation/emails_forward_creator_view.dart' deferred as emails_forward_creator;
import 'package:tmail_ui_user/features/contact/presentation/contact_view.dart' deferred as contact_view;
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_bindings.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_view.dart' deferred as rules_filter_creator;
import 'package:tmail_ui_user/features/login/presentation/login_bindings.dart';
import 'package:tmail_ui_user/features/login/presentation/login_view.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/login/presentation/login_view_web.dart' deferred as login;
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_view.dart' deferred as mailbox_creator;
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/mailbox_dashboard_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_view.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_view_web.dart' deferred as mailbox_dashboard;
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_view.dart' deferred as manage_account_dashboard;
import 'package:tmail_ui_user/features/session/presentation/session_page_bindings.dart';
import 'package:tmail_ui_user/features/session/presentation/session_view.dart' deferred as session;
import 'package:tmail_ui_user/main/pages/deferred_widget.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class AppPages {
  static final pagesOnlyOnMobile = [
    GetPage(
        name: AppRoutes.composer,
        opaque: false,
        page: () => DeferredWidget(composer.loadLibrary, () => composer.ComposerView()),
        binding: ComposerBindings()),
    GetPage(
        name: AppRoutes.destinationPicker,
        opaque: false,
        page: () => DeferredWidget(destination_picker.loadLibrary, () => destination_picker.DestinationPickerView()),
        binding: DestinationPickerBindings()),
    GetPage(
        name: AppRoutes.mailboxCreator,
        opaque: false,
        page: () => DeferredWidget(mailbox_creator.loadLibrary, () => mailbox_creator.MailboxCreatorView()),
        binding: MailboxCreatorBindings()),
    GetPage(
        name: AppRoutes.contact,
        opaque: false,
        page: () => DeferredWidget(contact_view.loadLibrary, () => contact_view.ContactView()),
        binding: ContactBindings()),
    GetPage(
        name: AppRoutes.identityCreator,
        opaque: false,
        page: () => DeferredWidget(identity_creator.loadLibrary, () => identity_creator.IdentityCreatorView()),
        binding: IdentityCreatorBindings()),
  ];

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
        name: AppRoutes.session,
        page: () => DeferredWidget(session.loadLibrary, () => session.SessionView()),
        binding: SessionPageBindings()),
    GetPage(
        name: AppRoutes.dashboard,
        page: () => DeferredWidget(mailbox_dashboard.loadLibrary, () => mailbox_dashboard.MailboxDashBoardView()),
        binding: MailboxDashBoardBindings()),
    GetPage(
        name: AppRoutes.settings,
        page: () => DeferredWidget(manage_account_dashboard.loadLibrary,
            () => manage_account_dashboard.ManageAccountDashBoardView()),
        binding: ManageAccountDashBoardBindings()),
    GetPage(
        name: AppRoutes.rulesFilterCreator,
        opaque: false,
        page: () => DeferredWidget(rules_filter_creator.loadLibrary,
            () => rules_filter_creator.RuleFilterCreatorView()),
        binding: RulesFilterCreatorBindings()),
    GetPage(
        name: AppRoutes.emailsForwardCreator,
        opaque: false,
        page: () => DeferredWidget(emails_forward_creator.loadLibrary,
            () => emails_forward_creator.EmailsForwardCreatorView()),
        binding: EmailsForwardCreatorBindings()),
    if (!BuildUtils.isWeb)
      ...pagesOnlyOnMobile
  ];
}
