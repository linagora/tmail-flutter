import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:labels/model/label.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/base/before_reconnect_manager.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/labels/domain/model/label_changes_result.dart';
import 'package:tmail_ui_user/features/labels/domain/state/get_all_label_state.dart';
import 'package:tmail_ui_user/features/labels/domain/state/get_label_changes_state.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/delete_a_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/get_all_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/get_label_changes_interactor.dart';
import 'package:tmail_ui_user/features/labels/presentation/extensions/handle_label_action_type_extension.dart';
import 'package:tmail_ui_user/features/labels/presentation/extensions/handle_label_websocket_extension.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_controller.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_label_setting_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_message.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../fixtures/account_fixtures.dart';
import '../../fixtures/session_fixtures.dart';
import 'label_controller_label_list_test.mocks.dart';

/// MailboxController leaves a label mailbox as soon as the label list
/// no longer holds its label, so every emitted list must be a final one.
@GenerateNiceMocks([
  MockSpec<CachingManager>(),
  MockSpec<LanguageCacheManager>(),
  MockSpec<AuthorizationInterceptors>(),
  MockSpec<DynamicUrlInterceptors>(),
  MockSpec<DeleteCredentialInteractor>(),
  MockSpec<LogoutOidcInteractor>(),
  MockSpec<DeleteAuthorityOidcInteractor>(),
  MockSpec<AppToast>(),
  MockSpec<ResponsiveUtils>(),
  MockSpec<Uuid>(),
  MockSpec<ToastManager>(),
  MockSpec<TwakeAppManager>(),
  MockSpec<BeforeReconnectManager>(),
  MockSpec<GetAllLabelInteractor>(),
  MockSpec<DeleteALabelInteractor>(),
  MockSpec<GetLabelChangesInteractor>(),
])
void main() {
  late LabelListHarness harness;

  setUp(() {
    registerBaseControllerDependencies();
    harness = LabelListHarness();
  });

  tearDown(Get.reset);

  group('LabelController label list', () {
    test('should emit the edited label list once, with the edited label', () {
      harness.controller.syncListLabels(renamedWork);

      expect(harness.emitted, [
        [renamedWork, home],
      ]);
    });

    test(
      'should emit a label updated over the websocket once, with the label',
      () => verifyWebsocketEmissions(
        harness,
        changes(updated: [renamedWork]),
        [
          [renamedWork, home],
        ],
      ),
    );

    test(
      'should emit a label destroyed over the websocket once, without the label',
      () => verifyWebsocketEmissions(
        harness,
        changes(destroyedIds: [work.id!]),
        [
          [home],
        ],
      ),
    );

    test('should keep the last labels when fetching labels fails', () {
      harness.controller.handleFailureViewState(
        GetAllLabelFailure(Exception()),
      );

      expect(harness.controller.labels, [home, work]);
      expect(harness.controller.isLabelsLoaded.isTrue, isTrue);
    });

    test('should clear the labels when reading the label setting fails', () {
      harness.controller.handleFailureViewState(
        GetLabelSettingStateFailure(Exception()),
      );

      expect(harness.controller.labels, isEmpty);
    });
  });
}

final home = Label(id: Id('home'), displayName: 'Home');
final work = Label(id: Id('work'), displayName: 'Work');
// Renamed to sort ahead of Home, so the emitted list must be re-sorted
final renamedWork = Label(id: Id('work'), displayName: 'Archive');
final newState = jmap.State('new-state');

void registerBaseControllerDependencies() {
  Get.testMode = true;
  Get.put<CachingManager>(MockCachingManager());
  Get.put<LanguageCacheManager>(MockLanguageCacheManager());
  final authorizationInterceptors = MockAuthorizationInterceptors();
  Get.put<AuthorizationInterceptors>(authorizationInterceptors);
  Get.put<AuthorizationInterceptors>(
    authorizationInterceptors,
    tag: BindingTag.isolateTag,
  );
  Get.put<DynamicUrlInterceptors>(MockDynamicUrlInterceptors());
  Get.put<DeleteCredentialInteractor>(MockDeleteCredentialInteractor());
  Get.put<LogoutOidcInteractor>(MockLogoutOidcInteractor());
  Get.put<DeleteAuthorityOidcInteractor>(MockDeleteAuthorityOidcInteractor());
  Get.put<AppToast>(MockAppToast());
  Get.put<ImagePaths>(ImagePaths());
  Get.put<ResponsiveUtils>(MockResponsiveUtils());
  Get.put<Uuid>(MockUuid());
  Get.put<ToastManager>(MockToastManager());
  Get.put<TwakeAppManager>(MockTwakeAppManager());
  Get.put<BeforeReconnectManager>(MockBeforeReconnectManager());
}

/// A [LabelController] holding Home and Work, with every emission of its
/// label list recorded.
class LabelListHarness {
  LabelListHarness() {
    // Registered first, so the bindings keep these instead of the real ones
    Get.put<GetAllLabelInteractor>(MockGetAllLabelInteractor());
    Get.put<DeleteALabelInteractor>(MockDeleteALabelInteractor());
    Get.put<GetLabelChangesInteractor>(getLabelChangesInteractor);

    controller
      ..checkLabelSettingState(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
      )
      ..injectLabelsBindings()
      ..setCurrentLabelState(jmap.State('old-state'));
    controller.labels.value = [home, work];
    ever<List<Label>>(
      controller.labels,
      (labels) => emitted.add(List.of(labels)),
    );
  }

  final controller = LabelController();
  final getLabelChangesInteractor = MockGetLabelChangesInteractor();
  final emitted = <List<Label>>[];
}

LabelChangesResult changes({
  List<Label> updated = const [],
  List<Id> destroyedIds = const [],
}) => LabelChangesResult(
  createdLabels: const [],
  updatedLabels: updated,
  destroyedLabelIds: destroyedIds,
  newState: newState,
);

Future<void> verifyWebsocketEmissions(
  LabelListHarness harness,
  LabelChangesResult changes,
  List<List<Label>> expected,
) async {
  when(harness.getLabelChangesInteractor.execute(any, any, any)).thenAnswer(
    (_) => Stream.value(Right(GetLabelChangesSuccess(changes))),
  );

  await harness.controller.handleWebSocketMessage(
    WebSocketMessage(newState: newState),
  );

  expect(harness.emitted, expected);
}
