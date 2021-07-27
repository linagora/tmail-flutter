import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:tmail_ui_user/features/home/presentation/home_bindings.dart';
import 'package:tmail_ui_user/features/home/presentation/home_view.dart';
import 'package:tmail_ui_user/features/login/presentation/login_bindings.dart';
import 'package:tmail_ui_user/features/login/presentation/login_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_bindings.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view.dart';
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
      name: AppRoutes.MAILBOX,
      page: () => MailboxView(),
      binding: MailboxBindings()),
  ];
}
