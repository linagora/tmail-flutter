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
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
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
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
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

/// Thread view off, set explicitly so these tests never depend on
/// FORCE_EMAIL_QUERY or the local thread setting.
class _ThreadViewOffController extends ThreadController {
  _ThreadViewOffController(
    super.getEmailsInMailboxInteractor,
    super.refreshChangesEmailsInMailboxInteractor,
    super.loadMoreEmailsInMailboxInteractor,
    super.getEmailByIdInteractor,
    super.cleanAndGetEmailsInMailboxInteractor,
  );

  @override
  bool get shouldCollapseThreads => false;
}

/// Pins how folder load-more behaves with thread view off. These tests must
/// keep passing unchanged when the load-more code is restructured.
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

    final controller = _ThreadViewOffController(
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

  void verifyNoGetAll() {
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

  group('folder load-more with thread view off', () {
    group('request', () {
      test('pages from the oldest listed email by date, without a position', () async {
        final listed = makeEmails(pageSize);
        final controller = createController(listed: listed);

        final request = await loadMore(controller);

        expect(request.limit, UnsignedInt(pageSize));
        expect(request.position, isNull);
        expect(
          request.filter,
          expectedFilter(mailbox: inbox, oldestEmail: listed.last),
        );
        expect(request.lastEmailId, listed.last.id);
        expect(request.useCache, isTrue);
        expect(request.collapseThreads, isFalse);
        expect(request.filterOption, FilterMessageOption.all);
      });

      test('sends no date bound and no anchor email when nothing is listed', () async {
        final controller = createController();

        final request = await loadMore(controller);

        expect(request.filter, expectedFilter(mailbox: inbox));
        expect(request.lastEmailId, isNull);
        expect(request.position, isNull);
      });

      test('reads the server, not the cache, in the starred folder', () async {
        final listed = makeEmails(pageSize);
        final starred = PresentationMailbox.favoriteFolder;
        final controller = createController(listed: listed, mailbox: starred);

        final request = await loadMore(controller);

        expect(request.useCache, isFalse);
        expect(
          request.filter,
          expectedFilter(mailbox: starred, oldestEmail: listed.last),
        );
        expect(request.lastEmailId, listed.last.id);
      });

      test('keeps the message filter option and the date bound', () async {
        final listed = makeEmails(pageSize);
        final controller = createController(
          listed: listed,
          filter: FilterMessageOption.unread,
        );

        final request = await loadMore(controller);

        expect(request.filterOption, FilterMessageOption.unread);
        expect(
          request.filter,
          expectedFilter(
            mailbox: inbox,
            filter: FilterMessageOption.unread,
            oldestEmail: listed.last,
          ),
        );
      });
    });

    group('guards', () {
      test('sends no request while another list load is shown as running', () async {
        final controller = createController(listed: makeEmails(pageSize));
        controller.loadingMoreStatus.value = LoadingMoreStatus.running;

        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();

        verifyNever(mockLoadMoreEmailsInMailboxInteractor.execute(any));
      });

      test('reports a failure and allows a retry when there is no session', () async {
        final controller = createController(
          listed: makeEmails(pageSize),
          withoutSession: true,
        );

        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();

        verifyNever(mockLoadMoreEmailsInMailboxInteractor.execute(any));
        expect(
          controller.viewState.value.fold((failure) => failure, (_) => null),
          isA<LoadMoreEmailsFailure>().having(
            (failure) => failure.exception,
            'exception',
            isA<NotFoundSessionException>(),
          ),
        );
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.completed);
        expect(controller.canLoadMore, isTrue);
      });
    });

    group('page result', () {
      test('appends a full page in order and allows more', () async {
        final listed = makeEmails(pageSize);
        final page = makeEmails(pageSize, from: pageSize);
        final controller = createController(listed: listed);
        answerLoadMorePage(page);

        await loadMore(controller);

        expect(displayedEmails.map((email) => email.id), [
          ...listed.map((email) => email.id),
          ...page.map((email) => email.id),
        ]);
        expect(controller.canLoadMore, isTrue);
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.completed);
      });

      test('drops emails that left the folder', () async {
        final listed = makeEmails(pageSize);
        final inFolder = makeEmails(1, from: pageSize);
        final elsewhere = makeEmails(1, from: pageSize + 1, mailboxId: otherMailboxId);
        final controller = createController(listed: listed);
        answerLoadMorePage([...inFolder, ...elsewhere]);

        await loadMore(controller);

        expect(displayedEmails.length, pageSize + 1);
        expect(displayedEmails.last.id, inFolder.single.id);
      });

      test('keeps emails from any mailbox in the starred folder', () async {
        final listed = makeEmails(pageSize);
        final elsewhere = makeEmails(2, from: pageSize, mailboxId: otherMailboxId);
        final controller = createController(
          listed: listed,
          mailbox: PresentationMailbox.favoriteFolder,
        );
        answerLoadMorePage(elsewhere);

        await loadMore(controller);

        expect(displayedEmails.length, pageSize + 2);
      });

      test('lists two emails of the same thread as two rows', () async {
        final listed = makeEmails(pageSize, threadOf: (_) => 'shared');
        final page = makeEmails(2, from: pageSize, threadOf: (_) => 'shared');
        final controller = createController(listed: listed);
        answerLoadMorePage(page);

        await loadMore(controller);

        expect(displayedEmails.length, pageSize + 2);
      });

      test('shows the spinner when the interactor reports loading', () async {
        final controller = createController(listed: makeEmails(pageSize));
        answerLoadMore(() => Stream.value(Right(LoadingMoreEmails())));

        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();

        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.running);
      });

      testWidgets('loads the next page on its own while the list is shorter than the screen',
          (tester) async {
        final listed = makeEmails(pageSize);
        final page = makeEmails(pageSize, from: pageSize);
        final controller = createController(listed: listed);
        await mountShortViewport(tester, controller);
        var call = 0;
        answerLoadMore(() {
          call++;
          return Stream.value(Right(LoadMoreEmailsSuccess(
            call == 1 ? page : const [],
            serverEmailCount: call == 1 ? pageSize : 0,
          )));
        });

        controller.handleLoadMoreEmailsRequest();
        await tester.pumpAndSettle();

        final requests = capturedLoadMoreRequests();
        expect(requests.length, 2);
        expect(requests.last.lastEmailId, page.last.id);
        expect(controller.canLoadMore, isFalse);
      });
    });

    group('failures and errors', () {
      test('keeps the list and allows a retry after a failed page', () async {
        final listed = makeEmails(pageSize);
        final controller = createController(listed: listed);
        answerLoadMore(() => Stream.value(Left(LoadMoreEmailsFailure(Exception('network')))));

        await loadMore(controller);

        expect(displayedEmails.length, pageSize);
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.completed);
        expect(controller.canLoadMore, isTrue);
      });

      test('stops the spinner on an urgent exception', () async {
        final controller = createController(listed: makeEmails(pageSize));
        PlatformInfo.isTestingForWeb = true;
        controller.loadingMoreStatus.value = LoadingMoreStatus.running;

        controller.handleUrgentException();

        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.idle);
      });

      test('leaves a finished load-more as finished on an unhandled error', () async {
        final controller = createController(listed: makeEmails(pageSize));
        controller.loadingMoreStatus.value = LoadingMoreStatus.completed;

        controller.handleErrorViewState(Exception('boom'), StackTrace.empty);

        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.completed);
      });
    });

    group('websocket refresh of a folder', () {
      test('reads back every listed email, beyond the server get limit', () async {
        final listed = makeEmails(600);
        final controller = createController();
        answerRefresh(listed);
        await startAndList(controller, listed);

        await pushEmailStateChange();

        expect(capturedRefreshArguments(), [UnsignedInt(600), false]);
      });

      test('reads back every listed email when the session has no get limit', () async {
        final listed = makeEmails(120);
        final controller = createController(session: sessionWithoutMaxObjectsInGet());
        answerRefresh(listed);
        await startAndList(controller, listed);

        await pushEmailStateChange();

        expect(capturedRefreshArguments(), [UnsignedInt(120), false]);
      });

      test('allows load-more again when the refresh brought changes', () async {
        final listed = makeEmails(pageSize);
        final controller = createController();
        answerRefresh(
          listed,
          changes: EmailChangeResponse(destroyed: [EmailId(Id('gone'))]),
        );
        await startAndList(controller, listed);
        controller.canLoadMore = false;

        await pushEmailStateChange();

        expect(controller.canLoadMore, isTrue);
      });

      test('still appends a page requested before the refresh landed', () async {
        final listed = makeEmails(pageSize);
        final page = makeEmails(pageSize, from: pageSize);
        final controller = createController();
        answerRefresh(listed);
        await startAndList(controller, listed);
        final pending = StreamController<Either<Failure, Success>>();
        addTearDown(pending.close);
        answerLoadMore(() => pending.stream);
        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();

        await pushEmailStateChange();
        pending.add(Right(LoadMoreEmailsSuccess(page, serverEmailCount: pageSize)));
        await pumpEventQueue();

        expect(displayedEmails.length, 2 * pageSize);
        expect(displayedEmails.last.id, page.last.id);
      });

      test('keeps the selection of listed emails', () async {
        final listed = makeEmails(pageSize);
        final controller = createController();
        answerRefresh(listed);
        await startAndList(controller, [
          listed.first.toSelectedEmail(selectMode: SelectMode.ACTIVE),
          ...listed.skip(1),
        ]);

        await pushEmailStateChange();

        expect(displayedEmails.first.selectMode, SelectMode.ACTIVE);
        expect(
          displayedEmails.skip(1).every((email) => email.selectMode != SelectMode.ACTIVE),
          isTrue,
        );
      });
    });

    group('websocket refresh of the starred folder', () {
      test('reads the listed count again from the server and replaces the list', () async {
        final listed = makeEmails(40, mailboxId: otherMailboxId);
        final refreshed = makeEmails(40, from: 100, mailboxId: otherMailboxId);
        final controller = createController(mailbox: PresentationMailbox.favoriteFolder);
        answerRefresh(listed);
        answerGetAll(() => Stream.value(Right(GetAllEmailSuccess(emailList: refreshed))));
        await startAndList(controller, listed);

        await pushEmailStateChange();

        verifyGetAll(
          limit: UnsignedInt(40),
          useCache: false,
          collapseThreads: false,
        ).called(1);
        expect(displayedEmails.map((email) => email.id), refreshed.map((email) => email.id));
      });

      test('turns load-more off when the read fails', () async {
        final listed = makeEmails(40, mailboxId: otherMailboxId);
        final controller = createController(mailbox: PresentationMailbox.favoriteFolder);
        answerRefresh(listed);
        answerGetAll(() => Stream.value(Left(GetAllEmailFailure(Exception('network')))));
        await startAndList(controller, listed);

        await pushEmailStateChange();

        expect(controller.canLoadMore, isFalse);
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.idle);
      });

      test('loads more only once the refresh has replaced the list', () async {
        final listed = makeEmails(40, mailboxId: otherMailboxId);
        final refreshed = makeEmails(40, from: 100, mailboxId: otherMailboxId);
        final controller = createController(mailbox: PresentationMailbox.favoriteFolder);
        answerRefresh(listed);
        final pendingRead = StreamController<Either<Failure, Success>>();
        addTearDown(pendingRead.close);
        answerGetAll(() => pendingRead.stream);
        await startAndList(controller, listed);

        await pushEmailStateChange();
        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();

        verifyNever(mockLoadMoreEmailsInMailboxInteractor.execute(any));

        pendingRead.add(Right(GetAllEmailSuccess(emailList: refreshed)));
        await pendingRead.close();
        await pumpEventQueue();

        final request = capturedLoadMoreRequests().single;
        expect(request.lastEmailId, refreshed.last.id);
      });

      test('sends again a page dropped by the refresh, from the refreshed list', () async {
        final listed = makeEmails(40, mailboxId: otherMailboxId);
        final refreshed = makeEmails(40, from: 100, mailboxId: otherMailboxId);
        final stalePage = makeEmails(pageSize, from: 40, mailboxId: otherMailboxId);
        final controller = createController(mailbox: PresentationMailbox.favoriteFolder);
        answerRefresh(listed);
        answerGetAll(() => Stream.value(Right(GetAllEmailSuccess(emailList: refreshed))));
        await startAndList(controller, listed);
        final pendingPage = StreamController<Either<Failure, Success>>();
        addTearDown(pendingPage.close);
        var call = 0;
        answerLoadMore(() => ++call == 1 ? pendingPage.stream : const Stream.empty());
        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();

        await pushEmailStateChange();
        pendingPage.add(Right(LoadMoreEmailsSuccess(stalePage, serverEmailCount: pageSize)));
        await pumpEventQueue();

        expect(displayedEmails.map((email) => email.id), refreshed.map((email) => email.id));
        final requests = capturedLoadMoreRequests();
        expect(requests.length, 2);
        expect(requests.last.lastEmailId, refreshed.last.id);
      });
    });

    group('user refresh actions', () {
      test('pull-to-refresh reloads the folder without forcing a server query', () async {
        final controller = createController(listed: makeEmails(pageSize));
        answerGetAll(() => const Stream.empty());

        await controller.onRefresh();

        verifyGetAll(forceEmailQuery: false, collapseThreads: false).called(1);
        expect(controller.canLoadMore, isFalse);
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.idle);
      });

      test('deep refresh clears the list and reloads one page through the clean-cache path', () async {
        final controller = createController(listed: makeEmails(pageSize));
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
        )).thenAnswer((_) => const Stream.empty());

        await controller.onCleanAndRefresh();

        expect(displayedEmails, isEmpty);
        verify(mockCleanAndGetEmailsInMailboxInteractor.execute(
          any,
          any,
          limit: UnsignedInt(pageSize),
          sort: anyNamed('sort'),
          emailFilter: anyNamed('emailFilter'),
          propertiesCreated: anyNamed('propertiesCreated'),
          propertiesUpdated: anyNamed('propertiesUpdated'),
          getLatestChanges: anyNamed('getLatestChanges'),
          useCache: anyNamed('useCache'),
        )).called(1);
        verifyNoGetAll();
      });

      test('refresh-all re-enables load-more and reloads the folder', () async {
        final controller = createController(listed: makeEmails(pageSize));
        answerGetAll(() => const Stream.empty());
        controller.canLoadMore = false;
        controller.loadingMoreStatus.value = LoadingMoreStatus.completed;

        await controller.refreshAllEmail();

        expect(controller.canLoadMore, isTrue);
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.idle);
        verifyGetAll(forceEmailQuery: false, collapseThreads: false).called(1);
      });

      test('drops a page requested before the folder was reloaded', () async {
        final listed = makeEmails(pageSize);
        final page = makeEmails(pageSize, from: pageSize);
        final controller = createController(listed: listed);
        answerGetAll(() => const Stream.empty());
        final pending = StreamController<Either<Failure, Success>>();
        addTearDown(pending.close);
        answerLoadMore(() => pending.stream);
        controller.handleLoadMoreEmailsRequest();
        await pumpEventQueue();

        controller.getAllEmailAction();
        pending.add(Right(LoadMoreEmailsSuccess(page, serverEmailCount: pageSize)));
        await pumpEventQueue();

        expect(displayedEmails.map((email) => email.id), listed.map((email) => email.id));
        expect(controller.loadingMoreStatus.value, LoadingMoreStatus.idle);
      });
    });
  });
}
