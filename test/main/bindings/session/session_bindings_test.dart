import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/check_sending_allowed_interactor.dart';
import 'package:tmail_ui_user/features/home/domain/repository/session_repository.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/main/bindings/session/session_bindings.dart';

class _MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  test(
    'SHOULD register the send check with the session interactor, '
    'so composers and the sending queue can find it',
  () {
    Get.put<SessionRepository>(_MockSessionRepository());

    SessionBindings().bindingsInteractor();

    expect(Get.find<GetSessionInteractor>(), isA<GetSessionInteractor>());
    expect(
      Get.find<CheckSendingAllowedInteractor>(),
      isA<CheckSendingAllowedInteractor>(),
    );
  });
}
