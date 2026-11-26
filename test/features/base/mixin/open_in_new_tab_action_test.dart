import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/email_action_controller.dart';
import 'package:tmail_ui_user/main/utils/app_route_tab_environment.dart';

class _RecordingTabEnvironment extends AppRouteTabEnvironment {
  final List<bool> isBasicAuthCalls = [];

  @override
  void openInNewTab(String url, {required bool isBasicAuth}) =>
      isBasicAuthCalls.add(isBasicAuth);
}

// EmailActionController finds the dashboard at construction; nothing else is used.
class _FakeDashboardController extends Fake implements MailboxDashBoardController {
  @override
  InternalFinalCallback<void> get onStart => InternalFinalCallback<void>(callback: () {});

  @override
  InternalFinalCallback<void> get onDelete => InternalFinalCallback<void>(callback: () {});
}

class _EmailHost with EmailActionController {
  _EmailHost(this.isAuthenticatedWithOidc, this.tabEnvironment);

  @override
  final bool isAuthenticatedWithOidc;
  @override
  final AppRouteTabEnvironment tabEnvironment;
  @override
  AccountId? get activeAccountId => null;
}

void main() {
  final email = PresentationEmail(routeWeb: Uri.parse('https://app.example.com/#/dashboard'));

  group('openEmailInNewTabAction', () {
    setUp(() {
      Get.put<MailboxDashBoardController>(_FakeDashboardController());
      Get.put(ResponsiveUtils());
      Get.put(ImagePaths());
    });

    tearDown(Get.reset);

    for (final (isOidc, isBasicAuth) in [(false, true), (true, false)]) {
      test('oidc=$isOidc opens with isBasicAuth=$isBasicAuth', () {
        final environment = _RecordingTabEnvironment();

        _EmailHost(isOidc, environment).openEmailInNewTabAction(email);

        expect(environment.isBasicAuthCalls, [isBasicAuth]);
      });
    }
  });
}
