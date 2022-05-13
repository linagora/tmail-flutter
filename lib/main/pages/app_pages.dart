import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart' deferred as composer;
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_bindings.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_view.dart' deferred as destination_picker;
import 'package:tmail_ui_user/features/email/presentation/email_view.dart' deferred as email;
import 'package:tmail_ui_user/features/home/presentation/home_bindings.dart';
import 'package:tmail_ui_user/features/home/presentation/home_view.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_bindings.dart';
import 'package:tmail_ui_user/features/login/presentation/login_bindings.dart';
import 'package:tmail_ui_user/features/login/presentation/login_view.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/login/presentation/login_view_web.dart' deferred as login;
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_view.dart' deferred as mailbox_creator;
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_view.dart' deferred as identity_creator;
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_view.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_view_web.dart' deferred as mailbox_dashboard;
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_view.dart' deferred as manage_account_dashboard;
import 'package:tmail_ui_user/features/session/presentation/session_page_bindings.dart';
import 'package:tmail_ui_user/features/session/presentation/session_view.dart' deferred as session;
import 'package:tmail_ui_user/main/pages/deferred_widget.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeView(),
      binding: HomeBindings()),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => DeferredWidget(login.loadLibrary, () => login.LoginView()),
      binding: LoginBindings()),
    GetPage(
      name: AppRoutes.SESSION,
      page: () => DeferredWidget(session.loadLibrary, () => session.SessionView()),
      binding: SessionPageBindings()),
    GetPage(
      name: AppRoutes.MAILBOX_DASHBOARD,
      page: () => DeferredWidget(mailbox_dashboard.loadLibrary, () => mailbox_dashboard.MailboxDashBoardView()),
      binding: MailboxDashBoardBindings()),
    GetPage(
      name: AppRoutes.EMAIL,
      page: () => DeferredWidget(email.loadLibrary, () => email.EmailView())),
    GetPage(
      name: AppRoutes.COMPOSER,
      opaque: false,
      page: () {
        ComposerBindings().dependencies();
        return DeferredWidget(composer.loadLibrary, () => composer.ComposerView());
      }),
    GetPage(
      name: AppRoutes.DESTINATION_PICKER,
      opaque: false,
      page: () => DeferredWidget(destination_picker.loadLibrary, () => destination_picker.DestinationPickerView()),
      binding: DestinationPickerBindings()),
    GetPage(
      name: AppRoutes.MAILBOX_CREATOR,
      opaque: false,
      page: () => DeferredWidget(mailbox_creator.loadLibrary, () => mailbox_creator.MailboxCreatorView()),
      binding: MailboxCreatorBindings()),
    GetPage(
      name: AppRoutes.MANAGE_ACCOUNT,
      page: () => DeferredWidget(manage_account_dashboard.loadLibrary, () => manage_account_dashboard.ManageAccountDashBoardView()),
      binding: ManageAccountDashBoardBindings()),
    GetPage(
      name: AppRoutes.IDENTITY_CREATOR,
      opaque: false,
      page: () => DeferredWidget(identity_creator.loadLibrary, () => identity_creator.IdentityCreatorView()),
      binding: IdentityCreatorBindings()),
  ];
}
