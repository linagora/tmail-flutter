import 'dart:async';

import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart' hide SearchController, State;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/get_email_request.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/load_more_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/refresh_changes_all_email_state.dart';
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/handle_pull_to_refresh_list_email_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/loading_more_status.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'thread_controller_test.mocks.dart';

class _ThreadControllerWithCollapseThreads extends ThreadController {
  _ThreadControllerWithCollapseThreads(
    super.getEmailsInMailboxInteractor,
    super.refreshChangesEmailsInMailboxInteractor,
    super.loadMoreEmailsInMailboxInteractor,
    super.getEmailByIdInteractor,
    super.cleanAndGetEmailsInMailboxInteractor, {
    required this.collapseThreads,
  });

  final bool collapseThreads;
  int handleUrgentExceptionCount = 0;

  @override
  bool get shouldCollapseThreads => collapseThreads;

  @override
  void handleUrgentException({Failure? failure, Exception? exception}) {
    handleUrgentExceptionCount++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNetworkConnectionController mockNetworkConnectionController;
  late MockSearchController mockSearchController;
  late MockMailboxDashBoardController mockMailboxDashBoardController;
  late MockGetEmailsInMailboxInteractor mockGetEmailsInMailboxInteractor;
  late MockRefreshChangesEmailsInMailboxInteractor mockRefreshChangesEmailsInMailboxInteractor;
  late MockLoadMoreEmailsInMailboxInteractor mockLoadMoreEmailsInMailboxInteractor;
  late MockGetEmailByIdInteractor mockGetEmailByIdInteractor;
  late MockCleanAndGetEmailsInMailboxInteractor mockCleanAndGetEmailsInMailboxInteractor;
  late MockCachingManager mockCachingManager;
  late MockLanguageCacheManager mockLanguageCacheManager;
  late MockAuthorizationInterceptors mockAuthorizationInterceptors;
  late MockDynamicUrlInterceptors mockDynamicUrlInterceptors;
  late MockDeleteCredentialInteractor mockDeleteCredentialInteractor;
  late MockLogoutOidcInteractor mockLogoutOidcInteractor;
  late MockDeleteAuthorityOidcInteractor mockDeleteAuthorityOidcInteractor;
  late MockAppToast mockAppToast;
  late MockImagePaths mockImagePaths;
  late MockResponsiveUtils mockResponsiveUtils;
  late MockUuid mockUuid;
  late MockToastManager mockToastManager;
  late MockTwakeAppManager mockTwakeAppManager;
  late MockSearchEmailInteractor mockSearchEmailInteractor;
  late MockSearchMoreEmailInteractor mockSearchMoreEmailInteractor;

  setUpAll(() {
    Get.testMode = true;
    mockCachingManager = MockCachingManager();
    mockLanguageCacheManager = MockLanguageCacheManager();
    mockAuthorizationInterceptors = MockAuthorizationInterceptors();
    mockDynamicUrlInterceptors = MockDynamicUrlInterceptors();
    mockDeleteCredentialInteractor = MockDeleteCredentialInteractor();
    mockLogoutOidcInteractor = MockLogoutOidcInteractor();
    mockDeleteAuthorityOidcInteractor = MockDeleteAuthorityOidcInteractor();
    mockAppToast = MockAppToast();
    mockImagePaths = MockImagePaths();
    mockResponsiveUtils = MockResponsiveUtils();
    mockUuid = MockUuid();
    mockToastManager = MockToastManager();
    mockTwakeAppManager = MockTwakeAppManager();

    Get.put<CachingManager>(mockCachingManager);
    Get.put<LanguageCacheManager>(mockLanguageCacheManager);
    Get.put<AuthorizationInterceptors>(mockAuthorizationInterceptors);
    Get.put<AuthorizationInterceptors>(
      mockAuthorizationInterceptors,
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(mockDynamicUrlInterceptors);
    Get.put<DeleteCredentialInteractor>(mockDeleteCredentialInteractor);
    Get.put<LogoutOidcInteractor>(mockLogoutOidcInteractor);
    Get.put<DeleteAuthorityOidcInteractor>(mockDeleteAuthorityOidcInteractor);
    Get.put<AppToast>(mockAppToast);
    Get.put<ImagePaths>(mockImagePaths);
    Get.put<ResponsiveUtils>(mockResponsiveUtils);
    Get.put<Uuid>(mockUuid);
    Get.put<ToastManager>(mockToastManager);
    Get.put<TwakeAppManager>(mockTwakeAppManager);

    mockNetworkConnectionController = MockNetworkConnectionController();
    mockSearchController = MockSearchController();
    mockMailboxDashBoardController = MockMailboxDashBoardController();
    mockGetEmailsInMailboxInteractor = MockGetEmailsInMailboxInteractor();
    mockRefreshChangesEmailsInMailboxInteractor =
        MockRefreshChangesEmailsInMailboxInteractor();
    mockLoadMoreEmailsInMailboxInteractor =
        MockLoadMoreEmailsInMailboxInteractor();
    mockSearchEmailInteractor = MockSearchEmailInteractor();
    mockSearchMoreEmailInteractor = MockSearchMoreEmailInteractor();
    mockGetEmailByIdInteractor = MockGetEmailByIdInteractor();
    mockCleanAndGetEmailsInMailboxInteractor =
        MockCleanAndGetEmailsInMailboxInteractor();

    Get.put<NetworkConnectionController>(mockNetworkConnectionController);
    Get.put<SearchController>(mockSearchController);
    Get.put<MailboxDashBoardController>(mockMailboxDashBoardController);
    Get.put<SearchEmailInteractor>(mockSearchEmailInteractor);
    Get.put<SearchMoreEmailInteractor>(mockSearchMoreEmailInteractor);
  });

  group('ThreadController::test', () {
    group('load-more request cursor test:', () {
      final mailboxId = MailboxId(Id('inbox'));
      final listedEmails = List.generate(
        3,
        (i) => PresentationEmail(
          id: EmailId(Id('cursor$i')),
          mailboxIds: {mailboxId: true},
          receivedAt: UTCDate(DateTime.utc(2026, 1, 10 - i)),
        ),
      );

      ThreadController? cursorController;

      tearDown(() {
        cursorController?.onClose();
        cursorController = null;
        clearInteractions(mockLoadMoreEmailsInMailboxInteractor);
      });

      GetEmailRequest captureLoadMoreRequest({required bool collapseThreads}) {
        final controller = cursorController = _ThreadControllerWithCollapseThreads(
          mockGetEmailsInMailboxInteractor,
          mockRefreshChangesEmailsInMailboxInteractor,
          mockLoadMoreEmailsInMailboxInteractor,
          mockGetEmailByIdInteractor,
          mockCleanAndGetEmailsInMailboxInteractor,
          collapseThreads: collapseThreads,
        );
        when(mockMailboxDashBoardController.searchController)
            .thenReturn(mockSearchController);
        when(mockSearchController.isSearchEmailRunning).thenReturn(false);
        when(mockMailboxDashBoardController.sessionCurrent)
            .thenReturn(SessionFixtures.aliceSession);
        when(mockMailboxDashBoardController.accountId)
            .thenReturn(Rxn(AccountFixtures.aliceAccountId));
        when(mockMailboxDashBoardController.selectedMailbox)
            .thenReturn(Rxn(PresentationMailbox(mailboxId)));
        when(mockMailboxDashBoardController.emailsInCurrentMailbox)
            .thenReturn(RxList(listedEmails));
        when(mockMailboxDashBoardController.filterMessageOption)
            .thenReturn(Rx(FilterMessageOption.all));
        when(mockLoadMoreEmailsInMailboxInteractor.execute(any))
            .thenAnswer((_) => const Stream.empty());
        clearInteractions(mockLoadMoreEmailsInMailboxInteractor);

        controller.handleLoadMoreEmailsRequest();

        return verify(mockLoadMoreEmailsInMailboxInteractor.execute(captureAny))
            .captured
            .single as GetEmailRequest;
      }

      test(
        'GIVEN threads are collapsed '
        'WHEN the folder loads more '
        'THEN the request SHOULD skip the listed threads by position, '
        'without a date bound or an anchor email',
      () {
        final request = captureLoadMoreRequest(collapseThreads: true);

        expect(request.position, listedEmails.length);
        expect(request.filter, EmailFilterCondition(inMailbox: mailboxId));
        expect(request.lastEmailId, isNull);
        expect(request.collapseThreads, isTrue);
      });

      test(
        'GIVEN threads are not collapsed '
        'WHEN the folder loads more '
        'THEN the request SHOULD page from the oldest listed email, '
        'without a position',
      () {
        final request = captureLoadMoreRequest(collapseThreads: false);

        expect(request.position, isNull);
        expect(
          request.filter,
          EmailFilterCondition(
            inMailbox: mailboxId,
            before: listedEmails.last.receivedAt,
          ),
        );
        expect(request.lastEmailId, listedEmails.last.id);
        expect(request.collapseThreads, isFalse);
      });
    });

    group('collapsed load-more overlapping page test:', () {
      final mailboxId = MailboxId(Id('inbox'));
      const pageSize = ThreadConstants.maxCountEmails;

      List<PresentationEmail> makeEmails(int count, {int from = 0}) =>
          List.generate(
            count,
            (i) => PresentationEmail(
              id: EmailId(Id('overlap${from + i}')),
              mailboxIds: {mailboxId: true},
            ),
          );

      late RxList<PresentationEmail> displayedEmails;
      late RxList<PresentationEmail> selectedEmails;
      late Rx<SelectMode> currentSelectMode;

      Session sessionWithoutMaxObjectsInGet() {
        final alice = SessionFixtures.aliceSession;
        return Session(
          Map.of(alice.capabilities)..remove(CapabilityIdentifier.jmapCore),
          {
            for (final entry in alice.accounts.entries)
              entry.key: Account(
                entry.value.name,
                entry.value.isPersonal,
                entry.value.isReadOnly,
                Map.of(entry.value.accountCapabilities)
                  ..remove(CapabilityIdentifier.jmapCore),
              ),
          },
          Map.of(alice.primaryAccounts)..remove(CapabilityIdentifier.jmapCore),
          alice.username,
          alice.apiUrl,
          alice.downloadUrl,
          alice.uploadUrl,
          alice.eventSourceUrl,
          alice.state,
        );
      }

      _ThreadControllerWithCollapseThreads createController({
        bool collapseThreads = true,
        int listedCount = pageSize,
        Session? session,
      }) {
        PlatformInfo.isTestingForWeb = false;
        clearInteractions(mockGetEmailsInMailboxInteractor);
        clearInteractions(mockLoadMoreEmailsInMailboxInteractor);
        displayedEmails = RxList(makeEmails(listedCount));
        selectedEmails = RxList();
        currentSelectMode = Rx(SelectMode.INACTIVE);
        when(mockMailboxDashBoardController.sessionCurrent)
            .thenReturn(session ?? SessionFixtures.aliceSession);
        when(mockMailboxDashBoardController.accountId)
            .thenReturn(Rxn(AccountFixtures.aliceAccountId));
        when(mockMailboxDashBoardController.selectedMailbox)
            .thenReturn(Rxn(PresentationMailbox(mailboxId)));
        when(mockMailboxDashBoardController.filterMessageOption)
            .thenReturn(Rx(FilterMessageOption.all));
        when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
        when(mockMailboxDashBoardController.isSelectionEnabled())
            .thenReturn(false);
        when(mockMailboxDashBoardController.listEmailSelected)
            .thenReturn(selectedEmails);
        when(mockMailboxDashBoardController.currentSelectMode)
            .thenReturn(currentSelectMode);
        when(mockMailboxDashBoardController.emailsInCurrentMailbox)
            .thenReturn(displayedEmails);
        when(mockMailboxDashBoardController.updateEmailList(any)).thenAnswer(
          (invocation) => displayedEmails.assignAll(
            invocation.positionalArguments.first as List<PresentationEmail>,
          ),
        );
        when(mockMailboxDashBoardController.searchController)
            .thenReturn(mockSearchController);
        when(mockSearchController.searchQuery).thenReturn(SearchQuery(''));
        when(mockSearchController.isSearchEmailRunning).thenReturn(false);

        final controller = _ThreadControllerWithCollapseThreads(
          mockGetEmailsInMailboxInteractor,
          mockRefreshChangesEmailsInMailboxInteractor,
          mockLoadMoreEmailsInMailboxInteractor,
          mockGetEmailByIdInteractor,
          mockCleanAndGetEmailsInMailboxInteractor,
          collapseThreads: collapseThreads,
        );
        addTearDown(() {
          controller.onClose();
          PlatformInfo.isTestingForWeb = false;
          clearInteractions(mockGetEmailsInMailboxInteractor);
          clearInteractions(mockLoadMoreEmailsInMailboxInteractor);
        });
        return controller;
      }

      void stubListReadAgain(Stream<Either<Failure, Success>> Function() answer) {
        when(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: anyNamed('forceEmailQuery'),
          collapseThreads: anyNamed('collapseThreads'),
        )).thenAnswer((_) => answer());
      }

      void stubListReadAgainReturns(List<PresentationEmail> emails) {
        stubListReadAgain(() => Stream.fromIterable([
              Right(GetAllEmailLoading()),
              Right(GetAllEmailSuccess(
                emailList: emails,
                currentMailboxId: mailboxId,
              )),
            ]));
      }

      VerificationResult verifyListReadAgain() {
        return verify(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: captureAnyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: false,
          forceEmailQuery: true,
          collapseThreads: true,
        ));
      }

      void verifyListNotReadAgain() {
        verifyNever(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: anyNamed('forceEmailQuery'),
          collapseThreads: anyNamed('collapseThreads'),
        ));
      }

      Future<void> loadMorePage(
        ThreadController controller,
        List<PresentationEmail> page, {
        int? serverEmailCount,
      }) async {
        when(mockLoadMoreEmailsInMailboxInteractor.execute(any)).thenAnswer(
          (_) => Stream.value(Right(LoadMoreEmailsSuccess(
            page,
            serverEmailCount: serverEmailCount ?? page.length,
          ))),
        );
        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();
      }

      /// A load-more page holding only the listed rows, as the server returns
      /// once new threads above them shifted the offset.
      Future<void> loadMoreOverlappingPage(ThreadController controller) =>
          loadMorePage(controller, displayedEmails.take(pageSize).toList());

      test(
        'GIVEN threads are collapsed '
        'WHEN a full load-more page holds only listed rows '
        'THEN the list SHOULD be read again from the server, one page longer',
      () async {
        final controller = createController();
        final readAgain = makeEmails(2 * pageSize);
        stubListReadAgainReturns(readAgain);

        await loadMoreOverlappingPage(controller);

        expect(verifyListReadAgain().captured, [UnsignedInt(2 * pageSize)]);
        expect(displayedEmails.map((email) => email.id), readAgain.map((email) => email.id));
        expect(controller.canLoadMore, isTrue);
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.completed);
      });

      test(
        'GIVEN 490 collapsed threads are listed '
        'WHEN a full load-more page holds only listed rows '
        'THEN the list SHOULD be read again with limit 500',
      () async {
        final controller = createController(listedCount: 490);
        stubListReadAgainReturns(makeEmails(500));

        await loadMoreOverlappingPage(controller);

        expect(verifyListReadAgain().captured, [UnsignedInt(500)]);
      });

      test(
        'GIVEN 500 collapsed threads are listed '
        'WHEN a full load-more page holds only listed rows '
        'THEN the list SHOULD NOT be read again AND load-more SHOULD continue '
        'from position 520',
      () async {
        final controller = createController(listedCount: 500);

        await loadMoreOverlappingPage(controller);

        verifyListNotReadAgain();
        expect(controller.canLoadMore, isTrue);
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.completed);

        clearInteractions(mockLoadMoreEmailsInMailboxInteractor);
        when(mockLoadMoreEmailsInMailboxInteractor.execute(any)).thenAnswer(
          (_) => Stream.value(Right(LoadMoreEmailsSuccess(
            makeEmails(pageSize, from: 1000),
            serverEmailCount: pageSize,
          ))),
        );
        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();

        final request = verify(
          mockLoadMoreEmailsInMailboxInteractor.execute(captureAny),
        ).captured.single as GetEmailRequest;
        expect(request.position, 520);
      });

      test(
        'GIVEN the session has no maxObjectsInGet '
        'WHEN an overlapping collapsed page is loaded '
        'THEN the list SHOULD be read again with the default get limit',
      () async {
        final controller = createController(
          listedCount: 40,
          session: sessionWithoutMaxObjectsInGet(),
        );
        stubListReadAgainReturns(makeEmails(50));

        await loadMoreOverlappingPage(controller);

        expect(verifyListReadAgain().captured, [UnsignedInt(50)]);
      });

      test(
        'GIVEN threads are collapsed '
        'WHEN the list read again holds 5 rows beyond the listed ones '
        'THEN load-more SHOULD continue',
      () async {
        final controller = createController();
        stubListReadAgainReturns(makeEmails(pageSize + 5));

        await loadMoreOverlappingPage(controller);

        expect(controller.canLoadMore, isTrue);
      });

      test(
        'GIVEN threads are collapsed '
        'WHEN the list read again holds no row beyond the listed ones '
        'THEN load-more SHOULD stop, the folder is exhausted',
      () async {
        final controller = createController();
        stubListReadAgainReturns(makeEmails(pageSize));

        await loadMoreOverlappingPage(controller);

        expect(verifyListReadAgain().callCount, 1);
        expect(controller.canLoadMore, isFalse);
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.completed);
      });

      test(
        'GIVEN threads are collapsed and the list is being read again '
        'WHEN load-more is requested before it completes '
        'THEN no other load-more request SHOULD be sent',
      () async {
        final controller = createController();
        final readAgain = StreamController<Either<Failure, Success>>();
        stubListReadAgain(() => readAgain.stream);
        // The stream can be listened to once, later tests need a fresh one.
        addTearDown(() => stubListReadAgainReturns(const []));
        await loadMoreOverlappingPage(controller);
        clearInteractions(mockLoadMoreEmailsInMailboxInteractor);

        controller.handleLoadMoreEmailsRequest();

        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.running);
        verifyNever(mockLoadMoreEmailsInMailboxInteractor.execute(any));

        readAgain.add(Right(GetAllEmailSuccess(
          emailList: makeEmails(2 * pageSize),
          currentMailboxId: mailboxId,
        )));
        await readAgain.close();
        await pumpEventQueue();

        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.completed);
      });

      test(
        'GIVEN threads are collapsed and the list was already read again at this size '
        'WHEN another full load-more page holds only listed rows '
        'THEN the list SHOULD NOT be read again AND load-more SHOULD stop',
      () async {
        final controller = createController();
        stubListReadAgainReturns(makeEmails(pageSize));

        await loadMoreOverlappingPage(controller);
        // A websocket change allows load-more again on the same rows.
        controller.canLoadMore = true;
        await loadMoreOverlappingPage(controller);

        expect(verifyListReadAgain().callCount, 1);
        expect(controller.canLoadMore, isFalse);
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.completed);
      });

      test(
        'GIVEN threads are collapsed and the list was read again at this size '
        'WHEN a page adds rows and the list later shrinks back to that size '
        'THEN an overlapping page SHOULD read the list again',
      () async {
        final controller = createController();
        stubListReadAgainReturns(makeEmails(pageSize));
        await loadMoreOverlappingPage(controller);

        controller.canLoadMore = true;
        final newRows = makeEmails(3, from: pageSize);
        await loadMorePage(controller, newRows, serverEmailCount: pageSize);
        displayedEmails.removeRange(0, newRows.length);
        await loadMoreOverlappingPage(controller);

        expect(verifyListReadAgain().callCount, 2);
      });

      test(
        'GIVEN threads are collapsed and the list was read again at this size '
        'WHEN the list is reset and loaded again to the same size '
        'THEN an overlapping page SHOULD read the list again',
      () async {
        final controller = createController();
        stubListReadAgainReturns(makeEmails(pageSize));
        await loadMoreOverlappingPage(controller);

        controller.resetToOriginalValue();
        displayedEmails.assignAll(makeEmails(pageSize));
        await loadMoreOverlappingPage(controller);

        expect(verifyListReadAgain().callCount, 2);
      });

      test(
        'GIVEN threads are collapsed '
        'WHEN reading the list again fails '
        'THEN the listed rows SHOULD stay AND load-more SHOULD be allowed again '
        'AND the dashboard refresh state SHOULD be a failure '
        'AND a second overlapping page SHOULD read the list again',
      () async {
        final controller = createController();
        final listedIds = displayedEmails.map((email) => email.id).toList();
        final readAgain = StreamController<Either<Failure, Success>>();
        stubListReadAgain(() => readAgain.stream);
        addTearDown(() => stubListReadAgainReturns(const []));
        await loadMoreOverlappingPage(controller);
        controller.canLoadMore = false;

        readAgain.add(Left(GetAllEmailFailure(Exception('network'))));
        await readAgain.close();
        await pumpEventQueue();

        expect(verifyListReadAgain().callCount, 1);
        expect(displayedEmails.map((email) => email.id), listedIds);
        expect(controller.canLoadMore, isTrue);
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.completed);
        verify(mockMailboxDashBoardController.updateRefreshAllEmailState(
          argThat(isA<Left<Failure, Success>>()),
        )).called(1);

        stubListReadAgainReturns(makeEmails(2 * pageSize));
        clearInteractions(mockGetEmailsInMailboxInteractor);
        await loadMoreOverlappingPage(controller);

        expect(verifyListReadAgain().callCount, 1);
      });

      test(
        'GIVEN the collapsed list re-read already failed once at this size '
        'WHEN it fails again '
        'THEN canLoadMore SHOULD be false AND a websocket refresh or browser resize '
        'SHOULD NOT start another re-read',
      () async {
        final controller = createController();
        final emailAction = Rxn<EmailUIAction>();
        when(mockMailboxDashBoardController.emailUIAction)
            .thenReturn(emailAction);
        when(mockMailboxDashBoardController.dashBoardAction)
            .thenReturn(Rxn());
        when(mockMailboxDashBoardController.viewState)
            .thenReturn(Rx(Right(UIState.idle)));
        when(mockMailboxDashBoardController.currentEmailState)
            .thenReturn(jmap.State('old-state'));
        when(mockMailboxDashBoardController.isEmailListDisplayed)
            .thenReturn(false);
        when(mockMailboxDashBoardController.isFirstSessionLoad)
            .thenReturn(false);
        when(mockRefreshChangesEmailsInMailboxInteractor.execute(
          any,
          any,
          any,
          sort: anyNamed('sort'),
          limit: anyNamed('limit'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          emailFilter: anyNamed('emailFilter'),
          collapseThreads: anyNamed('collapseThreads'),
        )).thenAnswer(
          (_) => Stream.value(Right(RefreshChangesAllEmailSuccess(
            emailList: displayedEmails.toList(),
            currentMailboxId: mailboxId,
            currentEmailState: jmap.State('new-state'),
          ))),
        );
        controller.onInit();
        stubListReadAgain(() => Stream.value(
              Left(GetAllEmailFailure(Exception('network'))),
            ));
        await loadMoreOverlappingPage(controller);
        controller.canLoadMore = true;
        await loadMoreOverlappingPage(controller);

        expect(controller.canLoadMore, isFalse);
        clearInteractions(mockGetEmailsInMailboxInteractor);

        emailAction.value = RefreshChangeEmailAction(
          newState: jmap.State('new-state'),
        );
        await pumpEventQueue();
        controller.canLoadMore = true;
        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();

        verifyListNotReadAgain();
      });

      test(
        'GIVEN a collapsed list re-read is pending '
        'WHEN it fails with BadCredentialsException '
        'THEN handleUrgentException SHOULD be called '
        'AND canLoadMore and loadingMoreStatus SHOULD not be modified afterwards',
      () async {
        final controller = createController();
        final pending = StreamController<Either<Failure, Success>>();
        addTearDown(() async {
          if (!pending.isClosed) await pending.close();
        });
        stubListReadAgain(() => pending.stream);
        await loadMoreOverlappingPage(controller);
        controller.canLoadMore = false;
        final statusBefore = controller.loadingMoreStatus.value;

        pending.add(Left(GetAllEmailFailure(const BadCredentialsException())));
        await pending.close();
        await pumpEventQueue();

        expect(controller.handleUrgentExceptionCount, 1);
        expect(controller.canLoadMore, isFalse);
        expect(controller.loadingMoreStatus.value, statusBefore);
      });

      test(
        'GIVEN a collapsed overlapping page is in flight '
        'WHEN the session is missing at re-read start '
        'THEN loadingMoreStatus SHOULD not be running AND the re-read guard SHOULD be cleared',
      () async {
        final controller = createController();
        when(mockLoadMoreEmailsInMailboxInteractor.execute(any)).thenAnswer(
          (_) => Stream.fromFuture(Future(
            () => Right(LoadMoreEmailsSuccess(
              displayedEmails.take(pageSize).toList(),
              serverEmailCount: pageSize,
            )),
          )),
        );
        controller.handleLoadMoreEmailsRequest();
        when(mockMailboxDashBoardController.sessionCurrent).thenReturn(null);
        await pumpEventQueue();

        expect(
          controller.loadingMoreStatus.value,
          isNot(LoadingMoreStatus.running),
        );
        when(mockMailboxDashBoardController.sessionCurrent)
            .thenReturn(SessionFixtures.aliceSession);
        controller.canLoadMore = true;
        stubListReadAgainReturns(makeEmails(2 * pageSize));
        clearInteractions(mockGetEmailsInMailboxInteractor);
        await loadMoreOverlappingPage(controller);
        expect(verifyListReadAgain().callCount, 1);
      });

      test(
        'GIVEN threads are collapsed '
        'WHEN a full load-more page adds rows '
        'THEN the rows SHOULD be appended AND the list SHOULD NOT be read again',
      () async {
        final controller = createController();
        final newRows = makeEmails(pageSize, from: pageSize);

        await loadMorePage(controller, newRows);

        verifyListNotReadAgain();
        expect(displayedEmails.length, 2 * pageSize);
        expect(controller.canLoadMore, isTrue);
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.completed);
      });

      test(
        'GIVEN threads are not collapsed '
        'WHEN a full load-more page holds only listed rows '
        'THEN the list SHOULD NOT be read again AND load-more SHOULD stop',
      () async {
        final controller = createController(collapseThreads: false);

        await loadMoreOverlappingPage(controller);

        verifyListNotReadAgain();
        expect(controller.canLoadMore, isFalse);
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.completed);
      });

      test(
        'GIVEN threads are collapsed '
        'WHEN a short load-more page holds only listed rows '
        'THEN the list SHOULD NOT be read again AND load-more SHOULD stop',
      () async {
        final controller = createController();

        await loadMorePage(controller, displayedEmails.take(5).toList());

        verifyListNotReadAgain();
        expect(controller.canLoadMore, isFalse);
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.completed);
      });

      test(
        'GIVEN selected rows on a collapsed list '
        'WHEN the list is read again after an overlapping page '
        'THEN those rows SHOULD stay selected in the server order',
      () async {
        final controller = createController();
        when(mockMailboxDashBoardController.isSelectionEnabled())
            .thenReturn(true);
        currentSelectMode.value = SelectMode.ACTIVE;
        final keptThread = ThreadId(Id('thread-keep'));
        displayedEmails.assignAll([
          displayedEmails.first.copyWith(
            threadId: keptThread,
            selectMode: SelectMode.ACTIVE,
          ),
          ...displayedEmails.skip(1),
        ]);
        final readAgain = [
          displayedEmails.first.copyWith(
            threadId: keptThread,
            selectMode: SelectMode.INACTIVE,
          ),
          ...makeEmails(2 * pageSize - 1, from: 1),
        ];
        stubListReadAgainReturns(readAgain);

        await loadMoreOverlappingPage(controller);

        expect(
          displayedEmails.map((email) => email.id),
          readAgain.map((email) => email.id),
        );
        expect(displayedEmails.first.selectMode, SelectMode.ACTIVE);
        expect(controller.listEmailSelected, [displayedEmails.first]);
      });

      test(
        'GIVEN a selected thread whose newest email id changed '
        'WHEN the list is read again '
        'THEN that thread SHOULD stay selected',
      () async {
        final controller = createController();
        when(mockMailboxDashBoardController.isSelectionEnabled())
            .thenReturn(true);
        currentSelectMode.value = SelectMode.ACTIVE;
        final keptThread = ThreadId(Id('thread-shifted'));
        displayedEmails.assignAll([
          displayedEmails.first.copyWith(
            id: EmailId(Id('old-head')),
            threadId: keptThread,
            selectMode: SelectMode.ACTIVE,
          ),
          ...displayedEmails.skip(1),
        ]);
        final newHead = PresentationEmail(
          id: EmailId(Id('new-head')),
          mailboxIds: {mailboxId: true},
          threadId: keptThread,
        );
        stubListReadAgainReturns([newHead, ...makeEmails(2 * pageSize - 1, from: 1)]);

        await loadMoreOverlappingPage(controller);

        expect(displayedEmails.first.id, newHead.id);
        expect(displayedEmails.first.selectMode, SelectMode.ACTIVE);
        expect(controller.listEmailSelected.map((email) => email.id), [newHead.id]);
      });

      test(
        'GIVEN selected threads that are gone from the re-read '
        'WHEN the list is read again '
        'THEN select mode SHOULD be off AND listEmailSelected SHOULD be empty',
      () async {
        final controller = createController();
        when(mockMailboxDashBoardController.isSelectionEnabled())
            .thenReturn(true);
        currentSelectMode.value = SelectMode.ACTIVE;
        displayedEmails.assignAll([
          displayedEmails.first.copyWith(
            threadId: ThreadId(Id('gone')),
            selectMode: SelectMode.ACTIVE,
          ),
          ...displayedEmails.skip(1),
        ]);
        stubListReadAgainReturns(makeEmails(2 * pageSize, from: 1000));

        await loadMoreOverlappingPage(controller);

        expect(
          mockMailboxDashBoardController.currentSelectMode.value,
          SelectMode.INACTIVE,
        );
        expect(controller.listEmailSelected, isEmpty);
        expect(
          displayedEmails.every((email) => email.selectMode == SelectMode.INACTIVE),
          isTrue,
        );
      });

      testWidgets(
        'GIVEN threads are collapsed and the list is scrolled down '
        'WHEN the list is read again after an overlapping page '
        'THEN the scroll position SHOULD be kept',
      (tester) async {
        final controller = createController();
        await tester.pumpWidget(MaterialApp(
          home: SizedBox(
            height: 300,
            child: ListView.builder(
              controller: controller.listEmailController,
              itemCount: 100,
              itemExtent: 50,
              itemBuilder: (_, index) => Text('$index'),
            ),
          ),
        ));
        controller.listEmailController.jumpTo(500);
        stubListReadAgainReturns(makeEmails(2 * pageSize));

        await tester.runAsync(() => loadMoreOverlappingPage(controller));
        await tester.pump();

        expect(verifyListReadAgain().callCount, 1);
        expect(controller.listEmailController.offset, 500);
      });
    });

    group('stale list results', () {
      final mailboxId = MailboxId(Id('inbox'));
      const pageSize = ThreadConstants.maxCountEmails;

      List<PresentationEmail> makeEmails(
        int count, {
        int from = 0,
        MailboxId? inMailbox,
        String prefix = 'stale',
      }) =>
          List.generate(
            count,
            (i) => PresentationEmail(
              id: EmailId(Id('$prefix${from + i}')),
              mailboxIds: {(inMailbox ?? mailboxId): true},
            ),
          );

      late RxList<PresentationEmail> displayedEmails;
      late Rx<FilterMessageOption> filterOption;
      late Rxn<PresentationMailbox> selectedMailbox;

      ThreadController createController({
        PresentationMailbox? mailbox,
        bool collapseThreads = true,
      }) {
        PlatformInfo.isTestingForWeb = false;
        displayedEmails = RxList(makeEmails(pageSize));
        filterOption = Rx(FilterMessageOption.all);
        selectedMailbox = Rxn(mailbox ?? PresentationMailbox(mailboxId));
        when(mockMailboxDashBoardController.sessionCurrent)
            .thenReturn(SessionFixtures.aliceSession);
        when(mockMailboxDashBoardController.accountId)
            .thenReturn(Rxn(AccountFixtures.aliceAccountId));
        when(mockMailboxDashBoardController.selectedMailbox)
            .thenReturn(selectedMailbox);
        when(mockMailboxDashBoardController.filterMessageOption)
            .thenReturn(filterOption);
        when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
        when(mockMailboxDashBoardController.isSelectionEnabled())
            .thenReturn(false);
        when(mockMailboxDashBoardController.listEmailSelected)
            .thenReturn(RxList());
        when(mockMailboxDashBoardController.currentSelectMode)
            .thenReturn(Rx(SelectMode.INACTIVE));
        when(mockMailboxDashBoardController.emailsInCurrentMailbox)
            .thenReturn(displayedEmails);
        when(mockMailboxDashBoardController.updateEmailList(any)).thenAnswer(
          (invocation) => displayedEmails.assignAll(
            invocation.positionalArguments.first as List<PresentationEmail>,
          ),
        );
        when(mockMailboxDashBoardController.searchController)
            .thenReturn(mockSearchController);
        when(mockMailboxDashBoardController.dashBoardAction)
            .thenReturn(Rxn());
        when(mockMailboxDashBoardController.emailUIAction)
            .thenReturn(Rxn());
        when(mockMailboxDashBoardController.viewState)
            .thenReturn(Rx(Right(UIState.idle)));
        when(mockMailboxDashBoardController.isEmailListDisplayed)
            .thenReturn(false);
        when(mockMailboxDashBoardController.isFirstSessionLoad)
            .thenReturn(false);
        when(mockSearchController.searchQuery).thenReturn(SearchQuery(''));
        when(mockSearchController.isSearchEmailRunning).thenReturn(false);
        when(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: anyNamed('forceEmailQuery'),
          collapseThreads: anyNamed('collapseThreads'),
        )).thenAnswer(
          (_) => Stream.value(Right(GetAllEmailSuccess(
            emailList: const [],
            currentMailboxId: mailboxId,
          ))),
        );
        when(mockLoadMoreEmailsInMailboxInteractor.execute(any)).thenAnswer(
          (_) => Stream.value(Right(LoadMoreEmailsSuccess(
            const [],
            serverEmailCount: 0,
          ))),
        );

        final controller = _ThreadControllerWithCollapseThreads(
          mockGetEmailsInMailboxInteractor,
          mockRefreshChangesEmailsInMailboxInteractor,
          mockLoadMoreEmailsInMailboxInteractor,
          mockGetEmailByIdInteractor,
          mockCleanAndGetEmailsInMailboxInteractor,
          collapseThreads: collapseThreads,
        );
        addTearDown(() {
          controller.onClose();
          PlatformInfo.isTestingForWeb = false;
          dotenv.clean();
        });
        return controller;
      }

      Future<void> startPendingResync(
        ThreadController controller,
        StreamController<Either<Failure, Success>> pending,
      ) async {
        addTearDown(() async {
          if (!pending.isClosed) await pending.close();
        });
        when(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: anyNamed('forceEmailQuery'),
          collapseThreads: anyNamed('collapseThreads'),
        )).thenAnswer((_) => pending.stream);
        when(mockLoadMoreEmailsInMailboxInteractor.execute(any)).thenAnswer(
          (_) => Stream.value(Right(LoadMoreEmailsSuccess(
            displayedEmails.take(pageSize).toList(),
            serverEmailCount: pageSize,
          ))),
        );
        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();
      }

      test(
        'GIVEN a collapsed list re-read is pending '
        'WHEN the filter changes to Unread and the stale re-read completes '
        'THEN the list and canLoadMore SHOULD stay the Unread ones',
      () async {
        final controller = createController();
        final pending = StreamController<Either<Failure, Success>>();
        await startPendingResync(controller, pending);

        final unreadEmails = makeEmails(pageSize, prefix: 'unread');
        when(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: anyNamed('forceEmailQuery'),
          collapseThreads: anyNamed('collapseThreads'),
        )).thenAnswer(
          (_) => Stream.value(Right(GetAllEmailSuccess(
            emailList: unreadEmails,
            currentMailboxId: mailboxId,
          ))),
        );
        controller.filterMessagesAction(FilterMessageOption.unread);
        await pumpEventQueue();

        pending.add(Right(GetAllEmailSuccess(
          emailList: makeEmails(2 * pageSize, prefix: 'stale-all'),
          currentMailboxId: mailboxId,
        )));
        await pending.close();
        await pumpEventQueue();

        expect(
          displayedEmails.map((email) => email.id),
          unreadEmails.map((email) => email.id),
        );
        expect(controller.canLoadMore, isTrue);
      });

      test(
        'GIVEN a collapsed list re-read is pending '
        'WHEN the mailbox is switched and the stale re-read completes '
        'THEN the new mailbox canLoadMore and loadingMoreStatus SHOULD stay untouched',
      () async {
        final controller = createController();
        controller.onInit();
        final pending = StreamController<Either<Failure, Success>>();
        await startPendingResync(controller, pending);
        controller.canLoadMore = false;
        controller.loadingMoreStatus.value = LoadingMoreStatus.idle;
        when(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: anyNamed('forceEmailQuery'),
          collapseThreads: anyNamed('collapseThreads'),
        )).thenAnswer(
          (_) => Stream.value(Right(GetAllEmailSuccess(
            emailList: makeEmails(pageSize, prefix: 'other'),
            currentMailboxId: MailboxId(Id('other')),
          ))),
        );

        selectedMailbox.value = PresentationMailbox(MailboxId(Id('other')));
        await pumpEventQueue();
        final canLoadMoreAfterSwitch = controller.canLoadMore;
        final statusAfterSwitch = controller.loadingMoreStatus.value;

        pending.add(Right(GetAllEmailSuccess(
          emailList: makeEmails(2 * pageSize, prefix: 'stale-mailbox'),
          currentMailboxId: mailboxId,
        )));
        await pending.close();
        await pumpEventQueue();

        expect(controller.canLoadMore, canLoadMoreAfterSwitch);
        expect(controller.loadingMoreStatus.value, statusAfterSwitch);
      });

      test(
        'GIVEN a collapsed list re-read is pending in Starred '
        'WHEN Action required is opened and the stale re-read completes '
        'THEN Starred rows SHOULD never be shown',
      () async {
        final starred = PresentationMailbox.favoriteFolder;
        final actionRequired = PresentationMailbox.actionRequiredFolder;
        final controller = createController(mailbox: starred);
        displayedEmails.assignAll(makeEmails(
          pageSize,
          inMailbox: starred.id,
          prefix: 'starred',
        ));
        controller.onInit();
        final pending = StreamController<Either<Failure, Success>>();
        await startPendingResync(controller, pending);
        when(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: anyNamed('forceEmailQuery'),
          collapseThreads: anyNamed('collapseThreads'),
        )).thenAnswer(
          (_) => Stream.value(Right(GetAllEmailSuccess(
            emailList: makeEmails(
              pageSize,
              inMailbox: actionRequired.id,
              prefix: 'action',
            ),
          ))),
        );

        selectedMailbox.value = actionRequired;
        await pumpEventQueue();
        displayedEmails.assignAll(makeEmails(
          pageSize,
          inMailbox: actionRequired.id,
          prefix: 'action',
        ));

        pending.add(Right(GetAllEmailSuccess(
          emailList: makeEmails(
            pageSize,
            inMailbox: starred.id,
            prefix: 'starred-stale',
          ),
        )));
        await pending.close();
        await pumpEventQueue();

        expect(
          displayedEmails.every(
            (email) => email.id?.id.value.startsWith('action') == true,
          ),
          isTrue,
        );
      });

      test(
        'GIVEN a collapsed list re-read is pending '
        'WHEN a websocket refresh changes the list and the stale re-read completes '
        'THEN the re-read SHOULD be dropped',
      () async {
        final controller = createController();
        final emailAction = Rxn<EmailUIAction>();
        when(mockMailboxDashBoardController.emailUIAction)
            .thenReturn(emailAction);
        when(mockMailboxDashBoardController.currentEmailState)
            .thenReturn(jmap.State('old-state'));
        when(mockRefreshChangesEmailsInMailboxInteractor.execute(
          any,
          any,
          any,
          sort: anyNamed('sort'),
          limit: anyNamed('limit'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          emailFilter: anyNamed('emailFilter'),
          collapseThreads: anyNamed('collapseThreads'),
        )).thenAnswer(
          (_) => Stream.value(Right(RefreshChangesAllEmailSuccess(
            emailList: makeEmails(pageSize, prefix: 'ws'),
            currentMailboxId: mailboxId,
            currentEmailState: jmap.State('new-state'),
          ))),
        );
        controller.onInit();
        final pending = StreamController<Either<Failure, Success>>();
        await startPendingResync(controller, pending);

        emailAction.value = RefreshChangeEmailAction(
          newState: jmap.State('new-state'),
        );
        await pumpEventQueue();

        pending.add(Right(GetAllEmailSuccess(
          emailList: makeEmails(2 * pageSize, prefix: 'stale-ws'),
          currentMailboxId: mailboxId,
        )));
        await pending.close();
        await pumpEventQueue();

        expect(
          displayedEmails.map((email) => email.id),
          makeEmails(pageSize, prefix: 'ws').map((email) => email.id),
        );
      });

      test(
        'GIVEN a collapsed load-more page is pending '
        'WHEN the filter changes '
        'THEN the old page SHOULD not be appended AND no re-read SHOULD start',
      () async {
        final controller = createController();
        final pendingPage = StreamController<Either<Failure, Success>>();
        addTearDown(pendingPage.close);
        when(mockLoadMoreEmailsInMailboxInteractor.execute(any))
            .thenAnswer((_) => pendingPage.stream);
        clearInteractions(mockGetEmailsInMailboxInteractor);
        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();

        final unreadEmails = makeEmails(pageSize, prefix: 'unread-page');
        when(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: anyNamed('forceEmailQuery'),
          collapseThreads: anyNamed('collapseThreads'),
        )).thenAnswer(
          (_) => Stream.value(Right(GetAllEmailSuccess(
            emailList: unreadEmails,
            currentMailboxId: mailboxId,
          ))),
        );
        clearInteractions(mockGetEmailsInMailboxInteractor);
        controller.filterMessagesAction(FilterMessageOption.unread);
        await pumpEventQueue();

        pendingPage.add(Right(LoadMoreEmailsSuccess(
          displayedEmails.take(pageSize).toList(),
          serverEmailCount: pageSize,
        )));
        await pendingPage.close();
        await pumpEventQueue();

        expect(
          displayedEmails.map((email) => email.id),
          unreadEmails.map((email) => email.id),
        );
        verifyNever(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: false,
          forceEmailQuery: true,
          collapseThreads: true,
        ));
      });

      test(
        'GIVEN a collapsed list was re-read at this size '
        'WHEN refreshAllEmail runs and an overlapping page arrives at the same size '
        'THEN the list SHOULD be read again',
      () async {
        final controller = createController();
        when(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: anyNamed('forceEmailQuery'),
          collapseThreads: anyNamed('collapseThreads'),
        )).thenAnswer(
          (_) => Stream.value(Right(GetAllEmailSuccess(
            emailList: makeEmails(pageSize),
            currentMailboxId: mailboxId,
          ))),
        );
        when(mockLoadMoreEmailsInMailboxInteractor.execute(any)).thenAnswer(
          (_) => Stream.value(Right(LoadMoreEmailsSuccess(
            displayedEmails.take(pageSize).toList(),
            serverEmailCount: pageSize,
          ))),
        );
        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();
        clearInteractions(mockGetEmailsInMailboxInteractor);

        await controller.refreshAllEmail();
        displayedEmails.assignAll(makeEmails(pageSize));
        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();

        verify(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: false,
          forceEmailQuery: true,
          collapseThreads: true,
        )).called(1);
      });

      test(
        'GIVEN a collapsed list re-read is pending '
        'WHEN the thread preference is toggled and the stale re-read completes '
        'THEN loadingMoreStatus SHOULD not be running AND a new load-more SHOULD be accepted',
      () async {
        final controller = createController();
        final pending = StreamController<Either<Failure, Success>>();
        await startPendingResync(controller, pending);
        when(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: anyNamed('forceEmailQuery'),
          collapseThreads: anyNamed('collapseThreads'),
        )).thenAnswer(
          (_) => Stream.value(Right(GetAllEmailSuccess(
            emailList: makeEmails(pageSize, prefix: 'pref'),
            currentMailboxId: mailboxId,
          ))),
        );

        controller.getAllEmailAction(forceEmailQuery: true);
        await pumpEventQueue();

        pending.add(Right(GetAllEmailSuccess(
          emailList: makeEmails(2 * pageSize, prefix: 'stale-pref'),
          currentMailboxId: mailboxId,
        )));
        await pending.close();
        await pumpEventQueue();

        expect(
          displayedEmails.map((email) => email.id),
          makeEmails(pageSize, prefix: 'pref').map((email) => email.id),
        );
        expect(
          controller.loadingMoreStatus.value,
          isNot(LoadingMoreStatus.running),
        );
        clearInteractions(mockLoadMoreEmailsInMailboxInteractor);
        when(mockLoadMoreEmailsInMailboxInteractor.execute(any)).thenAnswer(
          (_) => Stream.value(Right(LoadMoreEmailsSuccess(
            makeEmails(pageSize, from: pageSize, prefix: 'next'),
            serverEmailCount: pageSize,
          ))),
        );
        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();

        verify(mockLoadMoreEmailsInMailboxInteractor.execute(any)).called(1);
      });

      test(
        'GIVEN a collapsed list re-read is pending '
        'WHEN nothing else reloads the list '
        'THEN the result SHOULD be applied',
      () async {
        final controller = createController();
        final pending = StreamController<Either<Failure, Success>>();
        await startPendingResync(controller, pending);
        final readAgain = makeEmails(2 * pageSize, prefix: 'fresh');

        pending.add(Right(GetAllEmailSuccess(
          emailList: readAgain,
          currentMailboxId: mailboxId,
        )));
        await pending.close();
        await pumpEventQueue();

        expect(
          displayedEmails.map((email) => email.id),
          readAgain.map((email) => email.id),
        );
        expect(controller.canLoadMore, isTrue);
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.completed);
      });
    });

    group('pull-to-refresh with collapsed threads', () {
      final mailboxId = MailboxId(Id('inbox'));

      ThreadController createController({required bool collapseThreads}) {
        when(mockMailboxDashBoardController.sessionCurrent)
            .thenReturn(SessionFixtures.aliceSession);
        when(mockMailboxDashBoardController.accountId)
            .thenReturn(Rxn(AccountFixtures.aliceAccountId));
        when(mockMailboxDashBoardController.selectedMailbox)
            .thenReturn(Rxn(PresentationMailbox(mailboxId)));
        when(mockMailboxDashBoardController.filterMessageOption)
            .thenReturn(Rx(FilterMessageOption.all));
        when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
        when(mockMailboxDashBoardController.searchController)
            .thenReturn(mockSearchController);
        when(mockSearchController.isSearchEmailRunning).thenReturn(false);
        when(mockMailboxDashBoardController.emailsInCurrentMailbox)
            .thenReturn(RxList([]));
        when(mockMailboxDashBoardController.listEmailSelected)
            .thenReturn(RxList());
        when(mockMailboxDashBoardController.currentSelectMode)
            .thenReturn(Rx(SelectMode.INACTIVE));
        when(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: anyNamed('forceEmailQuery'),
          collapseThreads: anyNamed('collapseThreads'),
        )).thenAnswer(
          (_) => Stream.value(Right(GetAllEmailSuccess(
            emailList: const [],
            currentMailboxId: mailboxId,
          ))),
        );
        when(mockCleanAndGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
        )).thenAnswer(
          (_) => Stream.value(Right(GetAllEmailSuccess(
            emailList: const [],
            currentMailboxId: mailboxId,
          ))),
        );
        when(mockCachingManager.clearAllEmailAndStateCache())
            .thenAnswer((_) async {});

        final controller = _ThreadControllerWithCollapseThreads(
          mockGetEmailsInMailboxInteractor,
          mockRefreshChangesEmailsInMailboxInteractor,
          mockLoadMoreEmailsInMailboxInteractor,
          mockGetEmailByIdInteractor,
          mockCleanAndGetEmailsInMailboxInteractor,
          collapseThreads: collapseThreads,
        );
        addTearDown(controller.onClose);
        clearInteractions(mockGetEmailsInMailboxInteractor);
        clearInteractions(mockCleanAndGetEmailsInMailboxInteractor);
        clearInteractions(mockCachingManager);
        return controller;
      }

      VerificationResult verifyGetAllEmail({
        required bool forceEmailQuery,
        required bool collapseThreads,
      }) {
        return verify(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: forceEmailQuery,
          collapseThreads: collapseThreads,
        ));
      }

      setUp(() {
        dotenv.testLoad(fileInput: 'FORCE_EMAIL_QUERY=true');
        PlatformInfo.isTestingForWeb = true;
      });

      tearDown(() {
        dotenv.clean();
        PlatformInfo.isTestingForWeb = false;
      });

      test(
        'GIVEN threads are collapsed '
        'WHEN the list is pulled to refresh '
        'THEN the folder SHOULD be listed collapsed',
      () async {
        final controller = createController(collapseThreads: true);

        await controller.onRefresh();

        verifyGetAllEmail(forceEmailQuery: true, collapseThreads: true)
            .called(1);
      });

      test(
        'GIVEN threads are collapsed '
        'WHEN the list is deep-refreshed '
        'THEN the cache SHOULD be cleared AND the folder SHOULD be listed collapsed '
        'AND the clean interactor SHOULD NOT be called',
      () async {
        final controller = createController(collapseThreads: true);

        await controller.onCleanAndRefresh();

        verify(mockCachingManager.clearAllEmailAndStateCache()).called(1);
        verifyGetAllEmail(forceEmailQuery: true, collapseThreads: true)
            .called(1);
        verifyNever(mockCleanAndGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
        ));
      });

      test(
        'GIVEN thread view is off on web with FORCE_EMAIL_QUERY on '
        'WHEN the list is pulled to refresh '
        'THEN the folder SHOULD keep the cache path',
      () async {
        final controller = createController(collapseThreads: false);

        await controller.onRefresh();

        verifyGetAllEmail(forceEmailQuery: false, collapseThreads: false)
            .called(1);
      });

      test(
        'GIVEN thread view is off on web with FORCE_EMAIL_QUERY on '
        'WHEN the list is deep-refreshed '
        'THEN the clean interactor SHOULD be called as today',
      () async {
        final controller = createController(collapseThreads: false);

        await controller.onCleanAndRefresh();

        verify(mockCleanAndGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
        )).called(1);
        verifyNever(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: anyNamed('forceEmailQuery'),
          collapseThreads: anyNamed('collapseThreads'),
        ));
      });
    });

    group('virtual folder refresh with collapsed threads', () {
      final starred = PresentationMailbox.favoriteFolder;

      List<PresentationEmail> makeEmails(int count) => List.generate(
            count,
            (i) => PresentationEmail(
              id: EmailId(Id('vf$i')),
              mailboxIds: {starred.id: true},
            ),
          );

      late RxList<PresentationEmail> displayedEmails;
      late Rxn<EmailUIAction> emailAction;

      _ThreadControllerWithCollapseThreads createController({
        required bool collapseThreads,
      }) {
        displayedEmails = RxList();
        emailAction = Rxn();
        when(mockMailboxDashBoardController.sessionCurrent)
            .thenReturn(SessionFixtures.aliceSession);
        when(mockMailboxDashBoardController.accountId)
            .thenReturn(Rxn(AccountFixtures.aliceAccountId));
        when(mockMailboxDashBoardController.selectedMailbox)
            .thenReturn(Rxn(starred));
        when(mockMailboxDashBoardController.filterMessageOption)
            .thenReturn(Rx(FilterMessageOption.all));
        when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
        when(mockMailboxDashBoardController.searchController)
            .thenReturn(mockSearchController);
        when(mockSearchController.isSearchEmailRunning).thenReturn(false);
        when(mockSearchController.searchQuery).thenReturn(SearchQuery(''));
        when(mockMailboxDashBoardController.emailsInCurrentMailbox)
            .thenReturn(displayedEmails);
        when(mockMailboxDashBoardController.updateEmailList(any)).thenAnswer(
          (invocation) => displayedEmails.assignAll(
            invocation.positionalArguments.first as List<PresentationEmail>,
          ),
        );
        when(mockMailboxDashBoardController.listEmailSelected)
            .thenReturn(RxList());
        when(mockMailboxDashBoardController.currentSelectMode)
            .thenReturn(Rx(SelectMode.INACTIVE));
        when(mockMailboxDashBoardController.isSelectionEnabled())
            .thenReturn(false);
        when(mockMailboxDashBoardController.dashBoardAction).thenReturn(Rxn());
        when(mockMailboxDashBoardController.emailUIAction)
            .thenReturn(emailAction);
        when(mockMailboxDashBoardController.viewState)
            .thenReturn(Rx(Right(UIState.idle)));
        when(mockMailboxDashBoardController.currentEmailState)
            .thenReturn(jmap.State('old-state'));
        when(mockMailboxDashBoardController.isEmailListDisplayed)
            .thenReturn(false);
        when(mockMailboxDashBoardController.isFirstSessionLoad)
            .thenReturn(false);
        when(mockRefreshChangesEmailsInMailboxInteractor.execute(
          any,
          any,
          any,
          sort: anyNamed('sort'),
          limit: anyNamed('limit'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          emailFilter: anyNamed('emailFilter'),
          collapseThreads: anyNamed('collapseThreads'),
        )).thenAnswer(
          (_) => Stream.value(Right(RefreshChangesAllEmailSuccess(
            emailList: const [],
          ))),
        );
        when(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: anyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
          forceEmailQuery: anyNamed('forceEmailQuery'),
          collapseThreads: anyNamed('collapseThreads'),
        )).thenAnswer(
          (_) => Stream.value(Right(GetAllEmailSuccess(
            emailList: makeEmails(3),
            currentMailboxId: starred.id,
          ))),
        );

        final controller = _ThreadControllerWithCollapseThreads(
          mockGetEmailsInMailboxInteractor,
          mockRefreshChangesEmailsInMailboxInteractor,
          mockLoadMoreEmailsInMailboxInteractor,
          mockGetEmailByIdInteractor,
          mockCleanAndGetEmailsInMailboxInteractor,
          collapseThreads: collapseThreads,
        );
        addTearDown(() {
          controller.onClose();
          PlatformInfo.isTestingForWeb = false;
          dotenv.clean();
        });
        return controller;
      }

      Future<void> refreshVirtualFolder(ThreadController controller) async {
        clearInteractions(mockGetEmailsInMailboxInteractor);
        emailAction.value = RefreshChangeEmailAction(
          newState: jmap.State('new-state'),
        );
        await pumpEventQueue();
      }

      VerificationResult verifyVirtualFolderQuery({
        required bool forceEmailQuery,
        required bool collapseThreads,
      }) {
        return verify(mockGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: captureAnyNamed('limit'),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: false,
          forceEmailQuery: forceEmailQuery,
          collapseThreads: collapseThreads,
        ));
      }

      test(
        'GIVEN threads are collapsed and Starred is open '
        'WHEN a websocket change refreshes the folder '
        'THEN the folder query SHOULD force an email query of collapsed threads',
      () async {
        final controller = createController(collapseThreads: true);
        controller.onInit();

        await refreshVirtualFolder(controller);

        expect(
          verifyVirtualFolderQuery(
            forceEmailQuery: true,
            collapseThreads: true,
          ).callCount,
          1,
        );
      });

      test(
        'GIVEN 520 collapsed threads were listed in Starred '
        'WHEN a websocket change refreshes the folder '
        'THEN the folder query SHOULD be capped at maxObjectsInGet',
      () async {
        final controller = createController(collapseThreads: true);
        controller.onInit();
        displayedEmails.assignAll(makeEmails(520));

        await refreshVirtualFolder(controller);

        expect(
          verifyVirtualFolderQuery(
            forceEmailQuery: true,
            collapseThreads: true,
          ).captured,
          [UnsignedInt(500)],
        );
      });

      test(
        'GIVEN thread view is off on web with FORCE_EMAIL_QUERY '
        'WHEN a websocket change refreshes Starred '
        'THEN the folder query SHOULD keep the uncached path without forcing an email query',
      () async {
        dotenv.testLoad(fileInput: 'FORCE_EMAIL_QUERY=true');
        PlatformInfo.isTestingForWeb = true;
        final controller = createController(collapseThreads: false);
        controller.onInit();

        await refreshVirtualFolder(controller);

        expect(
          verifyVirtualFolderQuery(
            forceEmailQuery: false,
            collapseThreads: false,
          ).callCount,
          1,
        );
      });
    });
  });
}
