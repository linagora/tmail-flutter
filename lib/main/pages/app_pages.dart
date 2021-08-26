import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/home/presentation/home_bindings.dart';
import 'package:tmail_ui_user/features/home/presentation/home_view.dart';
import 'package:tmail_ui_user/features/login/presentation/login_bindings.dart';
import 'package:tmail_ui_user/features/login/presentation/login_view.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/features/session/presentation/session_bindings.dart';
import 'package:tmail_ui_user/features/session/presentation/session_view.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeView(),
      binding: HomeBindings()),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginView(),
      binding: LoginBindings()),
    GetPage(
      name: AppRoutes.SESSION,
      page: () => SessionView(),
      binding: SessionBindings()),
    GetPage(
      name: AppRoutes.MAILBOX,
      page: () => MailboxView()),
    GetPage(
      name: AppRoutes.MAILBOX_DASHBOARD,
      page: () => MailboxDashBoardView(),
      binding: MailboxDashBoardBindings()),
    GetPage(
      name: AppRoutes.THREAD,
      page: () => ThreadView()),
    GetPage(
      name: AppRoutes.EMAIL,
      page: () => EmailView()),
    GetPage(
      name: AppRoutes.COMPOSER,
      page: () => ComposerView(),
      binding: ComposerBindings()),
  ];
}
