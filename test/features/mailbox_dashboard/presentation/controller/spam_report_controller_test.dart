import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart' as jmap_mailbox;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/spam_report_exception.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_spam_mailbox_cached_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_spam_mailbox_cached_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_spam_report_state_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/store_last_time_dismissed_spam_reported_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/store_spam_report_state_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/spam_report_controller.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../../fixtures/active_account_bridge_fixtures.dart';
import '../../../../fixtures/delegation_fixtures.dart';
import '../../../../fixtures/widget_fixtures.dart';
import 'spam_report_controller_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<StoreSpamReportInteractor>(),
  MockSpec<StoreSpamReportStateInteractor>(),
  MockSpec<GetSpamReportStateInteractor>(),
  MockSpec<GetSpamMailboxCachedInteractor>(),
  // BaseController dependencies
  MockSpec<CachingManager>(),
  MockSpec<LanguageCacheManager>(),
  MockSpec<AuthorizationInterceptors>(),
  MockSpec<DynamicUrlInterceptors>(),
  MockSpec<DeleteCredentialInteractor>(),
  MockSpec<LogoutOidcInteractor>(),
  MockSpec<DeleteAuthorityOidcInteractor>(),
  MockSpec<AppToast>(),
  MockSpec<ImagePaths>(),
  MockSpec<ResponsiveUtils>(),
  MockSpec<ToastManager>(),
  MockSpec<TwakeAppManager>(),
  MockSpec<MailboxDashBoardController>(fallbackGenerators: fallbackGenerators),
])
void main() {
  late MockStoreSpamReportInteractor storeSpamReportInteractor;
  late MockStoreSpamReportStateInteractor storeSpamReportStateInteractor;
  late MockGetSpamReportStateInteractor getSpamReportStateInteractor;
  late MockGetSpamMailboxCachedInteractor getSpamMailboxCachedInteractor;
  late SpamReportController controller;

  PresentationMailbox makeMailboxWithUnread(int count) => PresentationMailbox(
    jmap_mailbox.MailboxId(Id('spam')),
    unreadEmails: jmap_mailbox.UnreadEmails(UnsignedInt(count)),
  );

  void putBaseControllerDependencies() {
    Get.put<CachingManager>(MockCachingManager());
    Get.put<LanguageCacheManager>(MockLanguageCacheManager());
    final authInterceptors = MockAuthorizationInterceptors();
    Get.put<AuthorizationInterceptors>(authInterceptors);
    Get.put<AuthorizationInterceptors>(authInterceptors, tag: BindingTag.isolateTag);
    Get.put<DynamicUrlInterceptors>(MockDynamicUrlInterceptors());
    Get.put<DeleteCredentialInteractor>(MockDeleteCredentialInteractor());
    Get.put<LogoutOidcInteractor>(MockLogoutOidcInteractor());
    Get.put<DeleteAuthorityOidcInteractor>(MockDeleteAuthorityOidcInteractor());
    Get.put<AppToast>(MockAppToast());
    Get.put<ImagePaths>(MockImagePaths());
    Get.put<ResponsiveUtils>(MockResponsiveUtils());
    Get.put<Uuid>(const Uuid());
    Get.put<ToastManager>(MockToastManager());
    Get.put<TwakeAppManager>(MockTwakeAppManager());
  }

  setUp(() {
    storeSpamReportInteractor = MockStoreSpamReportInteractor();
    storeSpamReportStateInteractor = MockStoreSpamReportStateInteractor();
    getSpamReportStateInteractor = MockGetSpamReportStateInteractor();
    getSpamMailboxCachedInteractor = MockGetSpamMailboxCachedInteractor();

    when(storeSpamReportInteractor.execute(any))
        .thenAnswer((_) => const Stream.empty());
    when(getSpamReportStateInteractor.execute())
        .thenAnswer((_) => const Stream.empty());

    putBaseControllerDependencies();

    controller = SpamReportController(
      storeSpamReportInteractor,
      storeSpamReportStateInteractor,
      getSpamReportStateInteractor,
      getSpamMailboxCachedInteractor,
    );
    Get.put(controller);
  });

  tearDown(Get.deleteAll);

  Stream<Either<Failure, Success>> failureStream(Exception exception) =>
      Stream.fromIterable([
        Right(GetSpamMailboxCachedLoading()),
        Left(GetSpamMailboxCachedFailure(exception)),
      ]);

  final testAccountId = AccountId(Id('acc'));
  final testUserName = UserName('user@example.com');

  group('SpamReportController._validateSpamMailboxChanged', () {
    group('NoUnreadSpamEmailsException', () {
      test('stores dismissal time when banner was showing with unread > 0', () async {
        controller.setSpamPresentationMailbox(makeMailboxWithUnread(3));

        when(getSpamMailboxCachedInteractor.execute(any, any))
            .thenAnswer((_) => failureStream(NoUnreadSpamEmailsException()));

        controller.getSpamMailboxCached(testAccountId, testUserName);
        await untilCalled(storeSpamReportInteractor.execute(any));

        verify(storeSpamReportInteractor.execute(any)).called(1);
        expect(controller.presentationSpamMailbox.value, isNull);
      });

      test('does not store dismissal when banner was not showing', () async {
        controller.setSpamPresentationMailbox(null);

        when(getSpamMailboxCachedInteractor.execute(any, any))
            .thenAnswer((_) => failureStream(NoUnreadSpamEmailsException()));

        controller.getSpamMailboxCached(testAccountId, testUserName);
        await pumpEventQueue();

        verifyNever(storeSpamReportInteractor.execute(any));
        expect(controller.presentationSpamMailbox.value, isNull);
      });

      test('does not store dismissal when banner mailbox has 0 unread', () async {
        controller.setSpamPresentationMailbox(makeMailboxWithUnread(0));

        when(getSpamMailboxCachedInteractor.execute(any, any))
            .thenAnswer((_) => failureStream(NoUnreadSpamEmailsException()));

        controller.getSpamMailboxCached(testAccountId, testUserName);
        await pumpEventQueue();

        verifyNever(storeSpamReportInteractor.execute(any));
        expect(controller.presentationSpamMailbox.value, isNull);
      });
    });

    group('SpamDismissCooldownActiveException', () {
      test('hides banner without storing dismissal time', () async {
        controller.setSpamPresentationMailbox(makeMailboxWithUnread(5));

        when(getSpamMailboxCachedInteractor.execute(any, any))
            .thenAnswer((_) => failureStream(SpamDismissCooldownActiveException()));

        controller.getSpamMailboxCached(testAccountId, testUserName);
        await pumpEventQueue();

        verifyNever(storeSpamReportInteractor.execute(any));
        expect(controller.presentationSpamMailbox.value, isNull);
      });
    });

    group('GetSpamMailboxCachedSuccess', () {
      test('shows banner with the returned mailbox', () async {
        final domainMailbox = jmap_mailbox.Mailbox(
          id: jmap_mailbox.MailboxId(Id('spam')),
          unreadEmails: jmap_mailbox.UnreadEmails(UnsignedInt(7)),
        );
        when(getSpamMailboxCachedInteractor.execute(any, any)).thenAnswer((_) =>
            Stream.fromIterable([
              Right(GetSpamMailboxCachedLoading()),
              Right(GetSpamMailboxCachedSuccess(domainMailbox)),
            ]));

        controller.getSpamMailboxCached(testAccountId, testUserName);
        await pumpEventQueue();

        expect(controller.presentationSpamMailbox.value, isNotNull);
      });
    });
  });

  group('SpamReportController.dismissSpamReportAction', () {
    testWidgets('marks the spam folder as read in the shown account, not in my own', (tester) async {
      final dashboard = MockMailboxDashBoardController();
      when(dashboard.sessionCurrent).thenReturn(DelegationFixtures.session());
      Get.put<MailboxDashBoardController>(dashboard);
      ActiveAccountBridgeFixtures.putShowing(DelegationFixtures.bobAccountId);
      controller.setSpamPresentationMailbox(makeMailboxWithUnread(3));
      late BuildContext context;
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
        child: Builder(builder: (builderContext) {
          context = builderContext;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      controller.dismissSpamReportAction(context);

      verify(dashboard.markAsReadMailbox(any, DelegationFixtures.bobAccountId, any, any, any)).called(1);
    });
  });
}
