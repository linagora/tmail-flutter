import 'package:core/data/network/download/download_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/add_a_label_to_a_thread_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/labels/remove_a_label_from_a_thread_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
    if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_star_multiple_email_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_emails_by_ids_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_thread_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_manager.dart';

import '../../../fixtures/active_account_bridge_fixtures.dart';
import '../../../fixtures/base_controller_fixtures.dart';
import '../../../fixtures/delegation_fixtures.dart';
import 'thread_detail_controller_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<GetThreadByIdInteractor>(),
  MockSpec<GetEmailsByIdsInteractor>(),
  MockSpec<MarkAsEmailReadInteractor>(),
  MockSpec<MarkAsStarEmailInteractor>(),
  MockSpec<PrintEmailInteractor>(),
  MockSpec<GetEmailContentInteractor>(),
  MockSpec<MarkAsStarMultipleEmailInteractor>(),
  MockSpec<MarkAsMultipleEmailReadInteractor>(),
  MockSpec<AddALabelToAThreadInteractor>(),
  MockSpec<RemoveALabelFromAThreadInteractor>(),
  MockSpec<MailboxDashBoardController>(fallbackGenerators: fallbackGenerators),
  MockSpec<NetworkConnectionController>(fallbackGenerators: fallbackGenerators),
  MockSpec<ThreadDetailManager>(fallbackGenerators: fallbackGenerators),
  MockSpec<DownloadManager>(),
])
void main() {
  setUp(() {
    BaseControllerFixtures.registerDependencies();
    Get.put<MailboxDashBoardController>(MockMailboxDashBoardController());
    Get.put<NetworkConnectionController>(MockNetworkConnectionController());
    Get.put<ThreadDetailManager>(MockThreadDetailManager());
    Get.put<DownloadManager>(MockDownloadManager());
    ActiveAccountBridgeFixtures.putShowing(DelegationFixtures.bobAccountId);
  });

  tearDown(Get.reset);

  test('reads the emails of the shown account, not of my own', () {
    final controller = ThreadDetailController(
      MockGetThreadByIdInteractor(),
      MockGetEmailsByIdsInteractor(),
      MockMarkAsEmailReadInteractor(),
      MockMarkAsStarEmailInteractor(),
      MockPrintEmailInteractor(),
      MockGetEmailContentInteractor(),
      MockMarkAsStarMultipleEmailInteractor(),
      MockMarkAsMultipleEmailReadInteractor(),
      MockAddALabelToAThreadInteractor(),
      MockRemoveALabelFromAThreadInteractor(),
    );

    expect(controller.accountId, DelegationFixtures.bobAccountId);
  });
}
