import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_authentication_account_interactor.dart';
import 'package:tmail_ui_user/features/mailto/presentation/model/mailto_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

class MailtoUrlController extends ReloadableController {

  MailtoUrlController(
    GetAuthenticatedAccountInteractor getAuthenticatedAccountInteractor,
    UpdateAuthenticationAccountInteractor updateAuthenticationAccountInteractor,
  ) : super(
    getAuthenticatedAccountInteractor,
    updateAuthenticationAccountInteractor
  );

  @override
  void onReady() {
    super.onReady();
    final parameters = Get.parameters;
    log('MailtoUrlController::onReady():parameters: $parameters');
    if (parameters.containsKey('uri')) {
      reload();
    } else {
      popAndPush(AppRoutes.unknownRoutePage);
    }
  }

  @override
  void handleReloaded(Session session) {
    final parameters = Get.parameters;
    log('MailtoUrlController::handleReloaded():parameters: $parameters');
    if (parameters.containsKey('uri')) {
      final mailtoArgument = MailtoArguments(
        session: session,
        emailAddress: parameters['uri']
      );
      popAndPush(
        RouteUtils.generateNavigationRoute(
          AppRoutes.dashboard,
          NavigationRouter.initial()
        ),
        arguments: mailtoArgument
      );
    } else {
      popAndPush(AppRoutes.unknownRoutePage);
    }
  }
}