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
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
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
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/get_email_request.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/load_more_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/refresh_changes_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/handle_pull_to_refresh_list_email_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/loading_more_status.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/filters/mailbox_filter_builder.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'thread_controller_test.mocks.dart';

/// Thread view on with server-collapsed threads, set explicitly so these
/// tests never depend on FORCE_EMAIL_QUERY or the local thread setting.
class _CollapsedThreadsController extends ThreadController {
  _CollapsedThreadsController(
    super.getEmailsInMailboxInteractor,
    super.refreshChangesEmailsInMailboxInteractor,
    super.loadMoreEmailsInMailboxInteractor,
    super.getEmailByIdInteractor,
    super.cleanAndGetEmailsInMailboxInteractor,
  );

  @override
  bool get shouldCollapseThreads => true;
}

/// Folder load-more with collapsed threads pages by offset and skips rows of
/// threads already listed.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSearchController mockSearchController;
  late MockMailboxDashBoardController mockMailboxDashBoardController;
  late MockGetEmailsInMailboxInteractor mockGetEmailsInMailboxInteractor;
  late MockRefreshChangesEmailsInMailboxInteractor mockRefreshChangesEmailsInMailboxInteractor;
  late MockLoadMoreEmailsInMailboxInteractor mockLoadMoreEmailsInMailboxInteractor;
  late MockGetEmailByIdInteractor mockGetEmailByIdInteractor;
  late MockCleanAndGetEmailsInMailboxInteractor mockCleanAndGetEmailsInMailboxInteractor;

  setUpAll(() {
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
    Get.put<ImagePaths>(MockImagePaths());
    Get.put<ResponsiveUtils>(MockResponsiveUtils());
    Get.put<Uuid>(MockUuid());
    Get.put<ToastManager>(MockToastManager());
    Get.put<TwakeAppManager>(MockTwakeAppManager());

    mockSearchController = MockSearchController();
    mockMailboxDashBoardController = MockMailboxDashBoardController();
    mockGetEmailsInMailboxInteractor = MockGetEmailsInMailboxInteractor();
    mockRefreshChangesEmailsInMailboxInteractor =
        MockRefreshChangesEmailsInMailboxInteractor();
    mockLoadMoreEmailsInMailboxInteractor =
        MockLoadMoreEmailsInMailboxInteractor();
    mockGetEmailByIdInteractor = MockGetEmailByIdInteractor();
    mockCleanAndGetEmailsInMailboxInteractor =
        MockCleanAndGetEmailsInMailboxInteractor();

    Get.put<NetworkConnectionController>(MockNetworkConnectionController());
    Get.put<SearchController>(mockSearchController);
    Get.put<MailboxDashBoardController>(mockMailboxDashBoardController);
    Get.put<SearchEmailInteractor>(MockSearchEmailInteractor());
    Get.put<SearchMoreEmailInteractor>(MockSearchMoreEmailInteractor());
  });

  final inboxId = MailboxId(Id('inbox'));
  final otherMailboxId = MailboxId(Id('other'));
  final inbox = PresentationMailbox(inboxId);
  const pageSize = ThreadConstants.maxCountEmails;

  /// Newest first, one minute apart, each email in its own thread unless
  /// [threadOf] says otherwise.
  List<PresentationEmail> makeEmails(
    int count, {
    int from = 0,
    MailboxId? mailboxId,
    String Function(int index)? threadOf,
  }) =>
      List.generate(count, (i) {
        final index = from + i;
        return PresentationEmail(
          id: EmailId(Id('email$index')),
          threadId: ThreadId(Id(threadOf?.call(index) ?? 'thread$index')),
          mailboxIds: {mailboxId ?? inboxId: true},
          receivedAt: UTCDate(
            DateTime.utc(2026, 1, 1).subtract(Duration(minutes: index)),
          ),
        );
      });

  late RxList<PresentationEmail> displayedEmails;
  late Rxn<PresentationMailbox> selectedMailbox;
  late Rx<FilterMessageOption> filterOption;
  late Rxn<EmailUIAction> emailUIAction;

  ThreadController createController({
    List<PresentationEmail> listed = const [],
    PresentationMailbox? mailbox,
    FilterMessageOption filter = FilterMessageOption.all,
    Session? session,
    bool withoutSession = false,
  }) {
    PlatformInfo.isTestingForWeb = false;
    reset(mockGetEmailsInMailboxInteractor);
    reset(mockRefreshChangesEmailsInMailboxInteractor);
    reset(mockLoadMoreEmailsInMailboxInteractor);
    reset(mockCleanAndGetEmailsInMailboxInteractor);

    displayedEmails = RxList(listed);
    selectedMailbox = Rxn(mailbox ?? inbox);
    filterOption = Rx(filter);
    emailUIAction = Rxn();

    when(mockMailboxDashBoardController.sessionCurrent).thenReturn(
      withoutSession ? null : session ?? SessionFixtures.aliceSession,
    );
    when(mockMailboxDashBoardController.accountId)
        .thenReturn(Rxn(AccountFixtures.aliceAccountId));
    when(mockMailboxDashBoardController.selectedMailbox)
        .thenReturn(selectedMailbox);
    when(mockMailboxDashBoardController.filterMessageOption)
        .thenReturn(filterOption);
    when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
    when(mockMailboxDashBoardController.isSelectionEnabled()).thenReturn(false);
    when(mockMailboxDashBoardController.listEmailSelected).thenReturn(RxList());
    when(mockMailboxDashBoardController.currentSelectMode)
        .thenReturn(Rx(SelectMode.INACTIVE));
    when(mockMailboxDashBoardController.emailsInCurrentMailbox)
        .thenReturn(displayedEmails);
    when(mockMailboxDashBoardController.updateEmailList(any)).thenAnswer(
      (invocation) => displayedEmails.assignAll(
        invocation.positionalArguments.first as List<PresentationEmail>,
      ),
    );
    when(mockMailboxDashBoardController.isEmailListDisplayed).thenReturn(false);
    when(mockMailboxDashBoardController.isFirstSessionLoad).thenReturn(false);
    when(mockMailboxDashBoardController.emailUIAction).thenReturn(emailUIAction);
    when(mockMailboxDashBoardController.dashBoardAction).thenReturn(Rxn());
    when(mockMailboxDashBoardController.viewState)
        .thenReturn(Rx(Right(UIState.idle)));
    when(mockMailboxDashBoardController.currentEmailState)
        .thenReturn(jmap.State('old-state'));
    when(mockMailboxDashBoardController.searchController)
        .thenReturn(mockSearchController);
    when(mockSearchController.searchQuery).thenReturn(SearchQuery(''));
    when(mockSearchController.isSearchEmailRunning).thenReturn(false);
    when(mockLoadMoreEmailsInMailboxInteractor.execute(any))
        .thenAnswer((_) => const Stream.empty());

    final controller = _CollapsedThreadsController(
      mockGetEmailsInMailboxInteractor,
      mockRefreshChangesEmailsInMailboxInteractor,
      mockLoadMoreEmailsInMailboxInteractor,
      mockGetEmailByIdInteractor,
      mockCleanAndGetEmailsInMailboxInteractor,
    );
    addTearDown(() {
      controller.onClose();
      PlatformInfo.isTestingForWeb = false;
    });
    return controller;
  }

  Filter expectedFilter({
    required PresentationMailbox mailbox,
    FilterMessageOption filter = FilterMessageOption.all,
    PresentationEmail? oldestEmail,
  }) {
    return MailboxFilterBuilder(
      selectedMailbox: mailbox,
      filterMessageOption: filter,
    ).buildFilterCondition(oldestEmail: oldestEmail);
  }

  void answerLoadMore(Stream<Either<Failure, Success>> Function() answer) {
    when(mockLoadMoreEmailsInMailboxInteractor.execute(any))
        .thenAnswer((_) => answer());
  }

  void answerLoadMorePage(List<PresentationEmail> page, {int? serverEmailCount}) {
    answerLoadMore(() => Stream.value(Right(LoadMoreEmailsSuccess(
          page,
          serverEmailCount: serverEmailCount ?? page.length,
        ))));
  }

  List<GetEmailRequest> capturedLoadMoreRequests() {
    return verify(mockLoadMoreEmailsInMailboxInteractor.execute(captureAny))
        .captured
        .cast<GetEmailRequest>();
  }

  Future<GetEmailRequest> loadMore(ThreadController controller) async {
    controller.handleLoadMoreEmailsRequest();
    await pumpEventQueue();
    return capturedLoadMoreRequests().single;
  }

  void answerGetAll(Stream<Either<Failure, Success>> Function() answer) {
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

  VerificationResult verifyGetAll({
    dynamic limit,
    dynamic useCache,
    dynamic forceEmailQuery,
    dynamic collapseThreads,
  }) {
    return verify(mockGetEmailsInMailboxInteractor.execute(
      any,
      any,
      limit: limit ?? anyNamed('limit'),
      sort: anyNamed('sort'),
      emailFilter: anyNamed('emailFilter'),
      propertiesCreated: anyNamed('propertiesCreated'),
      propertiesUpdated: anyNamed('propertiesUpdated'),
      getLatestChanges: anyNamed('getLatestChanges'),
      useCache: useCache ?? anyNamed('useCache'),
      forceEmailQuery: forceEmailQuery ?? anyNamed('forceEmailQuery'),
      collapseThreads: collapseThreads ?? anyNamed('collapseThreads'),
    ));
  }

  void answerRefresh(
    List<PresentationEmail> emails, {
    EmailChangeResponse? changes,
  }) {
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
    )).thenAnswer((_) => Stream.value(Right(RefreshChangesAllEmailSuccess(
          emailList: emails,
          currentMailboxId: selectedMailbox.value?.isVirtualFolder == true
              ? null
              : inboxId,
          currentEmailState: jmap.State('new-state'),
          emailChangeResponse: changes,
        ))));
  }

  List<dynamic> capturedRefreshArguments() {
    return verify(mockRefreshChangesEmailsInMailboxInteractor.execute(
      any,
      any,
      any,
      sort: anyNamed('sort'),
      limit: captureAnyNamed('limit'),
      propertiesCreated: anyNamed('propertiesCreated'),
      propertiesUpdated: anyNamed('propertiesUpdated'),
      emailFilter: anyNamed('emailFilter'),
      collapseThreads: captureAnyNamed('collapseThreads'),
    )).captured;
  }

  /// Starts the controller listeners, then lists [listed] so the peak count
  /// used by refreshes is [listed]'s length.
  Future<void> startAndList(
    ThreadController controller,
    List<PresentationEmail> listed,
  ) async {
    controller.onInit();
    await pumpEventQueue();
    displayedEmails.assignAll(listed);
    await pumpEventQueue();
  }

  Future<void> pushEmailStateChange() async {
    emailUIAction.value = RefreshChangeEmailAction(
      newState: jmap.State('new-state'),
    );
    await pumpEventQueue();
  }

  Future<void> mountShortViewport(
    WidgetTester tester,
    ThreadController controller,
  ) async {
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        height: 600,
        child: ListView(controller: controller.listEmailController),
      ),
    ));
  }


  group('folder load-more with collapsed threads', () {
    group('request', () {
      test('skips the listed rows by position, without a date bound or an anchor email', () async {
        final controller = createController(listed: makeEmails(pageSize));

        final request = await loadMore(controller);

        expect(request.position, pageSize);
        expect(request.filter, expectedFilter(mailbox: inbox));
        expect(request.lastEmailId, isNull);
        expect(request.collapseThreads, isTrue);
      });
    });

    group('page result', () {
      test('skips older replies of listed threads', () async {
        final listed = makeEmails(pageSize);
        final olderReply = PresentationEmail(
          id: EmailId(Id('older-reply')),
          threadId: listed.first.threadId,
          mailboxIds: {inboxId: true},
        );
        final controller = createController(listed: listed);
        answerLoadMorePage([olderReply, ...makeEmails(3, from: pageSize)]);

        await loadMore(controller);

        expect(displayedEmails.length, pageSize + 3);
        expect(displayedEmails.where((email) => email.id == olderReply.id), isEmpty);
      });

      test('appends the new threads of a page that new threads above partly shifted', () async {
        final listed = makeEmails(pageSize);
        final shiftedPage = [
          ...listed.skip(pageSize - 5),
          ...makeEmails(15, from: pageSize),
        ];
        final controller = createController(listed: listed);
        answerLoadMorePage(shiftedPage);

        await loadMore(controller);
        clearInteractions(mockLoadMoreEmailsInMailboxInteractor);
        answerLoadMore(() => const Stream.empty());
        final next = await loadMore(controller);

        expect(displayedEmails.length, pageSize + 15);
        expect(controller.canLoadMore, isTrue);
        expect(next.position, 2 * pageSize);
      });

      test('keeps going past a page holding only listed threads', () async {
        final listed = makeEmails(pageSize);
        final controller = createController(listed: listed);
        answerLoadMorePage(listed);

        await loadMore(controller);
        clearInteractions(mockLoadMoreEmailsInMailboxInteractor);
        answerLoadMore(() => const Stream.empty());
        final next = await loadMore(controller);

        expect(displayedEmails.length, pageSize);
        expect(controller.canLoadMore, isTrue);
        expect(next.position, 2 * pageSize);
      });

      testWidgets('reaches the end on its own after new threads shifted a whole page',
          (tester) async {
        final listed = makeEmails(pageSize);
        final controller = createController(listed: listed);
        await mountShortViewport(tester, controller);
        final pages = [listed, makeEmails(4, from: pageSize)];
        var call = 0;
        answerLoadMore(() {
          final page = pages[call++];
          return Stream.value(Right(LoadMoreEmailsSuccess(page, serverEmailCount: page.length)));
        });

        controller.handleLoadMoreEmailsRequest();
        await tester.pumpAndSettle();

        expect(capturedLoadMoreRequests().map((request) => request.position), [pageSize, 2 * pageSize]);
        expect(displayedEmails.length, pageSize + 4);
        expect(controller.canLoadMore, isFalse);
      });

      test('counts rows that do not belong in the folder in the offset', () async {
        final listed = makeEmails(pageSize);
        final controller = createController(listed: listed);
        answerLoadMorePage([
          ...makeEmails(17, from: pageSize),
          ...makeEmails(3, from: 2 * pageSize, mailboxId: otherMailboxId),
        ]);

        await loadMore(controller);
        clearInteractions(mockLoadMoreEmailsInMailboxInteractor);
        answerLoadMore(() => const Stream.empty());
        final next = await loadMore(controller);

        expect(displayedEmails.length, pageSize + 17);
        expect(next.position, 2 * pageSize);
      });

      test('ends the folder on a short page', () async {
        final controller = createController(listed: makeEmails(pageSize));
        answerLoadMorePage(makeEmails(7, from: pageSize));

        await loadMore(controller);

        expect(controller.canLoadMore, isFalse);
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.completed);
      });

      test('retries from the same position after a failed page', () async {
        final controller = createController(listed: makeEmails(pageSize));
        answerLoadMore(() => Stream.value(Left(LoadMoreEmailsFailure(Exception('network')))));

        await loadMore(controller);
        clearInteractions(mockLoadMoreEmailsInMailboxInteractor);
        answerLoadMore(() => const Stream.empty());
        final retry = await loadMore(controller);

        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.running);
        expect(retry.position, pageSize);
      });
    });

    group('list replaced from the top', () {
      test('drops a page requested against the rows the new list replaced', () async {
        final listed = makeEmails(pageSize);
        final reloaded = makeEmails(pageSize, from: 100);
        final controller = createController(listed: listed);
        final pending = StreamController<Either<Failure, Success>>();
        addTearDown(pending.close);
        answerLoadMore(() => pending.stream);
        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();

        controller.handleSuccessViewState(
          GetAllEmailSuccess(emailList: reloaded, currentMailboxId: inboxId),
        );
        pending.add(Right(LoadMoreEmailsSuccess(makeEmails(pageSize, from: pageSize), serverEmailCount: pageSize)));
        await pumpEventQueue();

        expect(displayedEmails.map((email) => email.id), reloaded.map((email) => email.id));
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.idle);
      });
    });

    group('websocket refresh of a folder', () {
      test('reads the server with the listed count capped at the session get limit', () async {
        final listed = makeEmails(600);
        final controller = createController();
        answerRefresh(listed.take(500).toList());
        await startAndList(controller, listed);

        await pushEmailStateChange();

        expect(capturedRefreshArguments(), [UnsignedInt(500), true]);
      });

      test('sends again a page dropped by the refresh, after the refreshed rows', () async {
        final listed = makeEmails(pageSize);
        final refreshed = makeEmails(pageSize + 2, from: 100);
        final controller = createController();
        answerRefresh(refreshed);
        await startAndList(controller, listed);
        final pendingPage = StreamController<Either<Failure, Success>>();
        addTearDown(pendingPage.close);
        var call = 0;
        answerLoadMore(() => ++call == 1 ? pendingPage.stream : const Stream.empty());
        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();

        await pushEmailStateChange();
        pendingPage.add(Right(LoadMoreEmailsSuccess(makeEmails(pageSize, from: pageSize), serverEmailCount: pageSize)));
        await pumpEventQueue();

        expect(displayedEmails.map((email) => email.id), refreshed.map((email) => email.id));
        final requests = capturedLoadMoreRequests();
        expect(requests.length, 2);
        expect(requests.last.position, pageSize + 2);
      });

      test('loads more only once the refresh has landed', () async {
        final listed = makeEmails(pageSize);
        final controller = createController();
        final pendingRefresh = StreamController<Either<Failure, Success>>();
        addTearDown(pendingRefresh.close);
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
        )).thenAnswer((_) => pendingRefresh.stream);
        await startAndList(controller, listed);

        await pushEmailStateChange();
        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();
        verifyNever(mockLoadMoreEmailsInMailboxInteractor.execute(any));

        pendingRefresh.add(Right(RefreshChangesAllEmailSuccess(
          emailList: listed,
          currentMailboxId: inboxId,
          currentEmailState: jmap.State('new-state'),
        )));
        await pendingRefresh.close();
        await pumpEventQueue();

        expect(capturedLoadMoreRequests().single.position, pageSize);
      });
    });

    group('websocket refresh of the starred folder', () {
      test('forces the collapsed server query', () async {
        final listed = makeEmails(40, mailboxId: otherMailboxId);
        final controller = createController(mailbox: PresentationMailbox.favoriteFolder);
        answerRefresh(listed);
        answerGetAll(() => const Stream.empty());
        await startAndList(controller, listed);

        await pushEmailStateChange();

        verifyGetAll(
          limit: UnsignedInt(40),
          useCache: false,
          forceEmailQuery: true,
          collapseThreads: true,
        ).called(1);
      });
    });

    group('user refresh actions', () {
      test('pull-to-refresh forces the collapsed server query', () async {
        final controller = createController(listed: makeEmails(pageSize));
        answerGetAll(() => const Stream.empty());

        await controller.onRefresh();

        verifyGetAll(forceEmailQuery: true, collapseThreads: true).called(1);
      });

      test('deep refresh reloads the folder with the collapsed server query, even while searching', () async {
        final controller = createController(listed: makeEmails(pageSize));
        when(mockSearchController.isSearchEmailRunning).thenReturn(true);
        answerGetAll(() => const Stream.empty());

        await controller.onCleanAndRefresh();

        expect(displayedEmails, isEmpty);
        verifyGetAll(forceEmailQuery: true, collapseThreads: true).called(1);
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
    });
  });
}
