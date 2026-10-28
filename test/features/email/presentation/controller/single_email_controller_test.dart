import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide State;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/calendar_event_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header_value.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_source.dart';
import 'package:tmail_ui_user/features/download/presentation/controllers/download_controller.dart';
import 'package:tmail_ui_user/features/email/data/datasource/calendar_event_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/html_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/repository/calendar_event_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_calendar_event_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/calendar_event_accept_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/calendar_event_counter_accept_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/calendar_event_reject_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/maybe_calendar_event_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_calendar_event_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/store_opened_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/calendar_event_interactor_bindings.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_address_bottom_sheet_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/model/blob_calendar_event.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/download_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rules_filter_creator_arguments.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/active_account_source_fixtures.dart';
import '../../../../fixtures/delegation_fixtures.dart';
import '../../../../fixtures/route_arguments_recorder.dart';
import 'single_email_controller_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<GetEmailContentInteractor>(),
  MockSpec<MarkAsEmailReadInteractor>(),
  MockSpec<MarkAsStarEmailInteractor>(),
  MockSpec<GetAllIdentitiesInteractor>(),
  MockSpec<StoreOpenedEmailInteractor>(),
  MockSpec<MailboxDashBoardController>(fallbackGenerators: fallbackGenerators),
  MockSpec<DownloadController>(fallbackGenerators: fallbackGenerators),
  MockSpec<DownloadManager>(fallbackGenerators: fallbackGenerators),
  MockSpec<CachingManager>(fallbackGenerators: fallbackGenerators),
  MockSpec<LanguageCacheManager>(fallbackGenerators: fallbackGenerators),
  MockSpec<AuthorizationInterceptors>(),
  MockSpec<DynamicUrlInterceptors>(),
  MockSpec<DeleteCredentialInteractor>(),
  MockSpec<LogoutOidcInteractor>(),
  MockSpec<DeleteAuthorityOidcInteractor>(),
  MockSpec<AppToast>(),
  MockSpec<ImagePaths>(),
  MockSpec<ResponsiveUtils>(),
  MockSpec<Uuid>(),
  MockSpec<PrintEmailInteractor>(),
  MockSpec<AcceptCalendarEventInteractor>(),
  MockSpec<MaybeCalendarEventInteractor>(),
  MockSpec<RejectCalendarEventInteractor>(),
  MockSpec<PrintUtils>(),
  MockSpec<ToastManager>(),
  MockSpec<CalendarEventDataSource>(),
  MockSpec<ParseCalendarEventInteractor>(),
  MockSpec<AcceptCounterCalendarEventInteractor>(),
  MockSpec<DioClient>(),
  MockSpec<TwakeAppManager>(),
  MockSpec<FileUploader>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final getEmailContentInteractor = MockGetEmailContentInteractor();
  final markAsEmailReadInteractor = MockMarkAsEmailReadInteractor();
  final markAsStarEmailInteractor = MockMarkAsStarEmailInteractor();
  final getAllIdentitiesInteractor = MockGetAllIdentitiesInteractor();
  final storeOpenedEmailInteractor = MockStoreOpenedEmailInteractor();
  final mailboxDashboardController = MockMailboxDashBoardController();
  final downloadController = MockDownloadController();
  final downloadManager = MockDownloadManager();
  final cachingManager = MockCachingManager();
  final languageCacheManager = MockLanguageCacheManager();
  final authorizationInterceptors = MockAuthorizationInterceptors();
  final dynamicUrlInterceptors = MockDynamicUrlInterceptors();
  final deleteCredentialInteractor = MockDeleteCredentialInteractor();
  final logoutOidcInteractor = MockLogoutOidcInteractor();
  final deleteAuthorityOidcInteractor = MockDeleteAuthorityOidcInteractor();
  final appToast = MockAppToast();
  final imagePaths = MockImagePaths();
  final responsiveUtils = MockResponsiveUtils();
  final uuid = MockUuid();
  final printEmailInteractor = MockPrintEmailInteractor();
  final printUtils = MockPrintUtils();
  final mockToastManager = MockToastManager();
  final mockTwakeAppManager = MockTwakeAppManager();

  late SingleEmailController singleEmailController;

  final testAccountId = AccountId(Id('123'));
  final google = Uri.parse('https://www.google.com');
  final testSession =
      Session({
        CapabilityIdentifier.jamesCalendarEvent: CalendarEventCapability(
          replySupportedLanguage: ['en', 'fr'],
        ),
      }, {}, {}, UserName('data'), google, google, google, google, State('1'));
  const testTaskId = 'taskId';

  setUpAll(() {
    Get.put<DownloadController>(downloadController);
    Get.put<MailboxDashBoardController>(mailboxDashboardController);
    Get.put<DownloadManager>(downloadManager);
    Get.put<CachingManager>(cachingManager);
    Get.put<LanguageCacheManager>(languageCacheManager);
    Get.put<AuthorizationInterceptors>(authorizationInterceptors);
    Get.put<AuthorizationInterceptors>(
      authorizationInterceptors,
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(dynamicUrlInterceptors);
    Get.put<DeleteCredentialInteractor>(deleteCredentialInteractor);
    Get.put<LogoutOidcInteractor>(logoutOidcInteractor);
    Get.put<DeleteAuthorityOidcInteractor>(deleteAuthorityOidcInteractor);
    Get.put<AppToast>(appToast);
    Get.put<ImagePaths>(imagePaths);
    Get.put<ResponsiveUtils>(responsiveUtils);
    Get.put<Uuid>(uuid);
    Get.put<PrintUtils>(printUtils);
    Get.put<ToastManager>(mockToastManager);
    Get.put<TwakeAppManager>(mockTwakeAppManager);

    when(mailboxDashboardController.accountId).thenReturn(Rxn(testAccountId));
    ActiveAccountSourceFixtures.putShowing(testAccountId);
    when(uuid.v4()).thenReturn(testTaskId);
  });

  setUp(() {
    singleEmailController = SingleEmailController(
      getEmailContentInteractor,
      markAsEmailReadInteractor,
      markAsStarEmailInteractor,
      getAllIdentitiesInteractor,
      storeOpenedEmailInteractor,
      printEmailInteractor,
    );
  });

  group('calendar event reply test:', () {
    final blobId = Id('abc123');
    final emailId = EmailId(Id('xyz123'));
    final calendarEvent = CalendarEvent();
    const locale = Locale('en', 'US');

    setUp(() {
      Get.locale = locale;
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    });

    group('accept test:', () {
      final acceptCalendarEventInteractor = MockAcceptCalendarEventInteractor();

      Future<void> replyYesToCalendarEvent() async {
        when(mailboxDashboardController.selectedEmail).thenReturn(Rxn(null));
        when(mailboxDashboardController.emailUIAction).thenReturn(Rxn(null));
        when(mailboxDashboardController.viewState).thenReturn(Rx(Right(UIState.idle)));
        when(mailboxDashboardController.sessionCurrent).thenReturn(testSession);
        when(mailboxDashboardController.downloadController).thenReturn(downloadController);
        when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));
        Get.put<AcceptCalendarEventInteractor>(acceptCalendarEventInteractor);
        singleEmailController.onInit();
        mailboxDashboardController.accountId.refresh();
        singleEmailController.handleSuccessViewState(
          ParseCalendarEventSuccess([
            BlobCalendarEvent(
              blobId: blobId,
              calendarEventList: [calendarEvent])]));

        singleEmailController.onCalendarEventReplyAction(EventActionType.yes, emailId);
        await untilCalled(acceptCalendarEventInteractor.execute(any, any, any, any));
      }

      test('should call execute on AcceptCalendarEventInteractor '
      'when onCalendarEventReplyAction is called on EventActionType.yes', () async {
        await replyYesToCalendarEvent();

        verify(acceptCalendarEventInteractor.execute(testAccountId, {blobId}, emailId, locale.languageCode)).called(1);
      });

      test('should accept the event in the shown account, not in my own', () async {
        ActiveAccountSourceFixtures.showForThisTest(DelegationFixtures.bobAccountId);

        await replyYesToCalendarEvent();

        verify(acceptCalendarEventInteractor.execute(
          DelegationFixtures.bobAccountId, {blobId}, emailId, locale.languageCode,
        )).called(1);
      });
    });

    group('maybe test:', () {
      final maybeCalendarEventInteractor = MockMaybeCalendarEventInteractor();

      test('should call execute on MaybeCalendarEventInteractor '
      'when onCalendarEventReplyAction is called on EventActionType.maybe', () async {
        // arrange
        when(mailboxDashboardController.selectedEmail).thenReturn(Rxn(null));
        when(mailboxDashboardController.emailUIAction).thenReturn(Rxn(null));
        when(mailboxDashboardController.viewState).thenReturn(Rx(Right(UIState.idle)));
        when(mailboxDashboardController.sessionCurrent).thenReturn(testSession);
        when(mailboxDashboardController.downloadController).thenReturn(downloadController);
        when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));
        Get.put<MaybeCalendarEventInteractor>(maybeCalendarEventInteractor);
        singleEmailController.onInit();
        mailboxDashboardController.accountId.refresh();
        singleEmailController.handleSuccessViewState(
          ParseCalendarEventSuccess([
            BlobCalendarEvent(
              blobId: blobId,
              calendarEventList: [calendarEvent])]));

        // act
        singleEmailController.onCalendarEventReplyAction(EventActionType.maybe, emailId);
        await untilCalled(maybeCalendarEventInteractor.execute(any, any, any, any));

        // assert
        verify(maybeCalendarEventInteractor.execute(testAccountId, {blobId}, emailId, locale.languageCode)).called(1);
      });
    });

    group('reject test:', () {
      final rejectCalendarEventInteractor = MockRejectCalendarEventInteractor();

      test('should call execute on RejectCalendarEventInteractor '
      'when onCalendarEventReplyAction is called on EventActionType.no', () async {
        // arrange
        when(mailboxDashboardController.selectedEmail).thenReturn(Rxn(null));
        when(mailboxDashboardController.emailUIAction).thenReturn(Rxn(null));
        when(mailboxDashboardController.viewState).thenReturn(Rx(Right(UIState.idle)));
        when(mailboxDashboardController.sessionCurrent).thenReturn(testSession);
        when(mailboxDashboardController.downloadController).thenReturn(downloadController);
        when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));
        Get.put<RejectCalendarEventInteractor>(rejectCalendarEventInteractor);
        singleEmailController.onInit();
        mailboxDashboardController.accountId.refresh();
        singleEmailController.handleSuccessViewState(
          ParseCalendarEventSuccess([
            BlobCalendarEvent(
              blobId: blobId,
              calendarEventList: [calendarEvent])]));

        // act
        singleEmailController.onCalendarEventReplyAction(EventActionType.no, emailId);
        await untilCalled(rejectCalendarEventInteractor.execute(any, any, any, any));

        // assert
        verify(rejectCalendarEventInteractor.execute(testAccountId, {blobId}, emailId, locale.languageCode)).called(1);
      });
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('_parseCalendarEventAction method test:', () {
    final calendarEventDataSource = MockCalendarEventDataSource();
    final calendarEventRepository = CalendarEventRepositoryImpl(
      {DataSourceType.network :calendarEventDataSource},
      HtmlDataSourceImpl(
        HtmlAnalyzer(
          HtmlTransform(
            MockDioClient(),
            const HtmlEscape(),
          ),
          MockFileUploader(),
          MockUuid(),
        ),
        CacheExceptionThrower(),
      ),
    );

    setUp(() {
      Get.put(ParseCalendarEventInteractor(calendarEventRepository));
    });

    tearDown(() {
      Get.delete<ParseCalendarEventInteractor>();
    });

    test(
      'should transform all calendar event description url to a tag '
      'and all new line to <br> tag',
    () async {
      // arrange
      const eventDescription = '\nhttps://example1.com\nhttps://example2.com';
      const expectedEventDescription = '<html><head></head><body>'
        '<a href="https://example1.com" target="_blank" rel="noreferrer" style="white-space: nowrap; word-break: keep-all;">example1.com</a>'
        '<br>'
        '<a href="https://example2.com" target="_blank" rel="noreferrer" style="white-space: nowrap; word-break: keep-all;">example2.com</a>'
        '</body></html>';
      final blobId = Id('abc123');
      final calendarEvent = CalendarEvent(
        description: eventDescription,
      );
      final blobCalendarEvents = [
        BlobCalendarEvent(
          blobId: blobId,
          calendarEventList: [calendarEvent],
        ),
      ];
      when(calendarEventDataSource.parse(any, any))
        .thenAnswer((_) async => blobCalendarEvents);

      when(mailboxDashboardController.selectedEmail).thenReturn(Rxn(PresentationEmail()));
      when(mailboxDashboardController.emailUIAction).thenReturn(Rxn(EmailUIAction()));
      when(mailboxDashboardController.viewState).thenReturn(Rx(Right(UIState.idle)));
      when(mailboxDashboardController.accountId).thenReturn(Rxn(AccountFixtures.aliceAccountId));
      when(mailboxDashboardController.downloadController).thenReturn(downloadController);
      when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));

      singleEmailController.onInit();
      mailboxDashboardController.accountId.refresh();

      // act
      singleEmailController.parseCalendarEventAction(
        accountId: AccountFixtures.aliceAccountId,
        blobIds: {blobId},
      );
      await untilCalled(calendarEventDataSource.parse(any, any));
      await Future.delayed(Duration.zero);

      // assert
      expect(
        singleEmailController.blobCalendarEvent.value,
        BlobCalendarEvent(
          blobId: blobId,
          calendarEventList: [CalendarEvent(description: expectedEventDescription)],
        ),
      );
    });

    test(
      'should transform all calendar event description url to a tag '
      'and all new line to <br> tag '
      'and remove all xss attempt',
    () async {
      // arrange
      const eventDescription = '\nhttps://example1.com'
        '\nhttps://example2.com'
        '\n<script>alert(1)</script>'
        '\n<a href="javascript:alert(1)">href xss</a>';
      const expectedEventDescription = '<html><head></head><body>'
        '<a href="https://example1.com" target="_blank" rel="noreferrer" style="white-space: nowrap; word-break: keep-all;">example1.com</a>'
        '<br>'
        '<a href="https://example2.com" target="_blank" rel="noreferrer" style="white-space: nowrap; word-break: keep-all;">example2.com</a>'
        '<br>'
        '<br>'
        '<a>href xss</a>'
        '</body></html>';
      final blobId = Id('abc123');
      final calendarEvent = CalendarEvent(
        description: eventDescription,
      );
      final blobCalendarEvents = [
        BlobCalendarEvent(
          blobId: blobId,
          calendarEventList: [calendarEvent],
        ),
      ];
      when(calendarEventDataSource.parse(any, any))
        .thenAnswer((_) async => blobCalendarEvents);

      when(mailboxDashboardController.selectedEmail).thenReturn(Rxn(PresentationEmail()));
      when(mailboxDashboardController.emailUIAction).thenReturn(Rxn(EmailUIAction()));
      when(mailboxDashboardController.viewState).thenReturn(Rx(Right(UIState.idle)));
      when(mailboxDashboardController.accountId).thenReturn(Rxn(AccountFixtures.aliceAccountId));
      when(mailboxDashboardController.downloadController).thenReturn(downloadController);
      when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));

      singleEmailController.onInit();
      mailboxDashboardController.accountId.refresh();
      
      // act
      singleEmailController.parseCalendarEventAction(
        accountId: AccountFixtures.aliceAccountId,
        blobIds: {blobId},
      );
      await untilCalled(calendarEventDataSource.parse(any, any));
      await Future.delayed(Duration.zero);

      // assert
      expect(
        singleEmailController.blobCalendarEvent.value,
        BlobCalendarEvent(
          blobId: blobId,
          calendarEventList: [CalendarEvent(description: expectedEventDescription)],
        ),
      );
    });

    test(
      'should render HTML markup in calendar event description as formatted HTML',
    () async {
      // arrange
      const eventDescription = '<p>Hello <b>world</b></p>';
      final blobId = Id('abc123');
      final calendarEvent = CalendarEvent(description: eventDescription);
      final blobCalendarEvents = [
        BlobCalendarEvent(
          blobId: blobId,
          calendarEventList: [calendarEvent],
        ),
      ];
      when(calendarEventDataSource.parse(any, any))
        .thenAnswer((_) async => blobCalendarEvents);

      when(mailboxDashboardController.selectedEmail).thenReturn(Rxn(PresentationEmail()));
      when(mailboxDashboardController.emailUIAction).thenReturn(Rxn(EmailUIAction()));
      when(mailboxDashboardController.viewState).thenReturn(Rx(Right(UIState.idle)));
      when(mailboxDashboardController.accountId).thenReturn(Rxn(AccountFixtures.aliceAccountId));
      when(mailboxDashboardController.downloadController).thenReturn(downloadController);
      when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));

      singleEmailController.onInit();
      mailboxDashboardController.accountId.refresh();

      // act
      singleEmailController.parseCalendarEventAction(
        accountId: AccountFixtures.aliceAccountId,
        blobIds: {blobId},
      );
      await untilCalled(calendarEventDataSource.parse(any, any));
      await Future.delayed(Duration.zero);

      // assert — HTML tags must be rendered, not escaped as visible text
      final description = singleEmailController
          .blobCalendarEvent.value?.calendarEventList.first.description ?? '';
      expect(description, contains('<p>'));
      expect(description, contains('<b>world</b>'));
      expect(description, isNot(contains('&lt;p&gt;')));
      expect(description, isNot(contains('&lt;b&gt;')));
    });
  });

  Widget makeTestableWidget({required Widget child}) {
    return GetMaterialApp(
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  testWidgets(
    'should show retry toast '
    'when handleFailureViewState is called with GetEmailContentFailure',
    (tester) async {
      // arrange
      when(mailboxDashboardController.selectedEmail).thenReturn(Rxn(PresentationEmail()));
      when(mailboxDashboardController.emailUIAction).thenReturn(Rxn(EmailUIAction()));
      when(mailboxDashboardController.viewState).thenReturn(Rx(Right(UIState.idle)));
      when(mailboxDashboardController.downloadController).thenReturn(downloadController);
      when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));
      when(imagePaths.icUndo).thenReturn(ImagePaths().icUndo);
      when(imagePaths.icClose).thenReturn(ImagePaths().icClose);
      Get.put(singleEmailController);
      final widget = makeTestableWidget(child: const _TestView());
      await tester.pumpWidget(widget);
      await tester.pump();

      // act
      singleEmailController.handleFailureViewState(GetEmailContentFailure(
        null,
        onRetry: const Stream.empty(),
      ));
      await tester.pump();

      // assert
      final captured = verify(appToast.showToastMessageWithMultipleActions(
        any,
        captureAny,
        actions: captureAnyNamed('actions'),
        textColor: anyNamed('textColor'),
        backgroundColor: anyNamed('backgroundColor'),
        infinityToast: anyNamed('infinityToast'),
      )).captured;
      expect(captured[0], AppLocalizations().unknownError);
      final actions = captured[1] as List<({String? actionName, Function? onActionClick, Widget? actionIcon})>;
      expect(actions.any((a) => a.actionName == AppLocalizations().retry), isTrue);
      expect(actions.any((a) => a.actionName == AppLocalizations().close), isTrue);

      // cleanup
      Get.delete<SingleEmailController>();
    },
  );

  group('calendar event of the shown account:', () {
    final parseCalendarEventInteractor = MockParseCalendarEventInteractor();
    final calendarBlobId = Id('calendar-blob-id');
    final calendarEmailId = EmailId(Id('calendar-email-id'));
    final calendarAttachments = [
      Attachment(blobId: calendarBlobId, type: MediaType('text', Attachment.eventCalendarSubtype)),
    ];
    // Both accounts support calendar events, so only the account passed to the parse tells them apart.
    Account calendarAccount(String name) => Account(AccountName(name), true, false, {
          CapabilityIdentifier.jamesCalendarEvent: CalendarEventCapability(replySupportedLanguage: ['en']),
        });
    final calendarSession = Session(
      {CapabilityIdentifier.jamesCalendarEvent: CalendarEventCapability(replySupportedLanguage: ['en'])},
      {
        testAccountId: calendarAccount(DelegationFixtures.aliceAddress),
        DelegationFixtures.bobAccountId: calendarAccount(DelegationFixtures.bobAddress),
      },
      {}, UserName('data'), google, google, google, google, State('1'));

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      // Registered first, so the calendar bindings the shown account gets keep these mocks.
      Get.put<ParseCalendarEventInteractor>(parseCalendarEventInteractor);
      Get.put<AcceptCalendarEventInteractor>(MockAcceptCalendarEventInteractor());
      Get.put<MaybeCalendarEventInteractor>(MockMaybeCalendarEventInteractor());
      Get.put<RejectCalendarEventInteractor>(MockRejectCalendarEventInteractor());
      Get.put<AcceptCounterCalendarEventInteractor>(MockAcceptCounterCalendarEventInteractor());
      addTearDown(() {
        CalendarEventInteractorBindings().dispose();
        Get.delete<HtmlDataSource>();
        Get.delete<HtmlDataSourceImpl>();
        // The dashboard mock is shared by the whole file: later tests must not get calendar bindings.
        when(mailboxDashboardController.sessionCurrent).thenReturn(testSession);
        when(mailboxDashboardController.selectedEmail).thenReturn(Rxn(null));
      });
      reset(parseCalendarEventInteractor);
      when(parseCalendarEventInteractor.execute(any, any, any)).thenAnswer((_) => const Stream.empty());
      when(storeOpenedEmailInteractor.execute(any, any, any)).thenAnswer((_) => const Stream.empty());
      when(mailboxDashboardController.selectedEmail).thenReturn(Rxn(PresentationEmail(
        id: calendarEmailId,
        headerCalendarEvent: const TextHeaderValue('calendar-event'),
      )));
      when(mailboxDashboardController.emailUIAction).thenReturn(Rxn(null));
      when(mailboxDashboardController.viewState).thenReturn(Rx(Right(UIState.idle)));
      when(mailboxDashboardController.sessionCurrent).thenReturn(calendarSession);
      when(mailboxDashboardController.mapMailboxById).thenReturn({});
      when(mailboxDashboardController.downloadController).thenReturn(downloadController);
      when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));
      when(mailboxDashboardController.accountId).thenReturn(Rxn(testAccountId));
      ActiveAccountSourceFixtures.showForThisTest(DelegationFixtures.bobAccountId);
      singleEmailController.onInit();
      mailboxDashboardController.accountId.refresh();
    });

    test('an email loaded from the server parses its calendar event in the shown account, not in my own', () {
      singleEmailController.handleSuccessViewState(GetEmailContentSuccess(
        htmlEmailContent: '',
        attachments: calendarAttachments,
        emailCurrent: Email(id: calendarEmailId),
      ));

      verify(parseCalendarEventInteractor.execute(DelegationFixtures.bobAccountId, {calendarBlobId}, any)).called(1);
      verifyNoMoreInteractions(parseCalendarEventInteractor);
    });

    test('an email loaded from the offline cache parses its calendar event in the shown account, not in my own', () {
      singleEmailController.handleSuccessViewState(GetEmailContentFromCacheSuccess(
        htmlEmailContent: '',
        attachments: calendarAttachments,
        emailCurrent: Email(id: calendarEmailId),
      ));

      verify(parseCalendarEventInteractor.execute(DelegationFixtures.bobAccountId, {calendarBlobId}, any)).called(1);
      verifyNoMoreInteractions(parseCalendarEventInteractor);
    });
  });

  group('email content of the shown account:', () {
    final openedEmailId = EmailId(Id('opened-email-id'));

    setUp(() {
      addTearDown(() {
        when(mailboxDashboardController.selectedEmail).thenReturn(Rxn(null));
        reset(getEmailContentInteractor);
      });
      when(mailboxDashboardController.selectedEmail).thenReturn(Rxn(PresentationEmail(
        id: openedEmailId,
        keywords: {KeyWordIdentifier.emailSeen: true},
      )));
      when(mailboxDashboardController.emailUIAction).thenReturn(Rxn(null));
      when(mailboxDashboardController.viewState).thenReturn(Rx(Right(UIState.idle)));
      when(mailboxDashboardController.sessionCurrent).thenReturn(testSession);
      when(mailboxDashboardController.mapMailboxById).thenReturn({});
      when(mailboxDashboardController.downloadController).thenReturn(downloadController);
      when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));
    });

    testWidgets('the content of an account shown before never reaches the opened email once another one is shown',
        (tester) async {
      ActiveAccountSourceFixtures.showForThisTest(DelegationFixtures.bobAccountId);
      final source = Get.find<ActiveAccountSource>() as FakeActiveAccountSource;
      final bobContent = StreamController<Either<Failure, Success>>();
      addTearDown(bobContent.close);
      when(getEmailContentInteractor.execute(any, any, any, any, any)).thenAnswer((_) => bobContent.stream);
      singleEmailController.onInit();
      await tester.pumpWidget(const SizedBox());
      verify(getEmailContentInteractor.execute(any, DelegationFixtures.bobAccountId, openedEmailId, any, any))
          .called(1);

      source.show(DelegationFixtures.carolAccountId);
      bobContent.add(Right(GetEmailContentSuccess(
        htmlEmailContent: 'content of bob',
        emailCurrent: Email(id: openedEmailId),
      )));
      await tester.pump();

      expect(singleEmailController.emailContents.value, isNull);
      expect(
        singleEmailController.emailLoadedViewState.value.fold((failure) => failure, (success) => success),
        isA<GetEmailContentLoading>(),
      );
    });
  });

  group('quick rule filter:', () {
    setUp(() {
      when(mailboxDashboardController.selectedEmail).thenReturn(Rxn(null));
      when(mailboxDashboardController.emailUIAction).thenReturn(Rxn(null));
      when(mailboxDashboardController.viewState).thenReturn(Rx(Right(UIState.idle)));
      when(mailboxDashboardController.sessionCurrent).thenReturn(testSession);
      when(mailboxDashboardController.downloadController).thenReturn(downloadController);
      when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));
    });

    testWidgets('quickCreatingRule creates the rule in my own account while it is shown', (tester) async {
      singleEmailController.onInit();
      final recorder = await RouteArgumentsRecorder.pump(tester, AppRoutes.rulesFilterCreator);
      // quickCreatingRule and the rule creation each close what opened them first.
      unawaited(Get.to(() => const SizedBox.shrink()));
      unawaited(Get.to(() => const SizedBox.shrink()));
      await tester.pumpAndSettle();

      singleEmailController.quickCreatingRule(EmailAddress('Carol', DelegationFixtures.carolAddress));
      await tester.pumpAndSettle();

      expect((recorder.arguments as RulesFilterCreatorArguments).accountId, testAccountId);
    });

    testWidgets('the quick rule of the email address dialog is created in my own account while it is shown',
        (tester) async {
      singleEmailController.onInit();
      final recorder = await RouteArgumentsRecorder.pump(tester, AppRoutes.rulesFilterCreator);

      singleEmailController.openEmailAddressDialog(EmailAddress('Carol', DelegationFixtures.carolAddress));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppLocalizations.of(recorder.context).quickCreatingRule));
      await tester.pumpAndSettle();

      expect((recorder.arguments as RulesFilterCreatorArguments).accountId, testAccountId);
    });

    testWidgets('the email address dialog has no quick rule while a delegated account is shown',
        (tester) async {
      ActiveAccountSourceFixtures.putForThisTest(
        DelegationFixtures.session(),
        shownAccountId: DelegationFixtures.bobAccountId,
      );
      singleEmailController.onInit();
      final recorder = await RouteArgumentsRecorder.pump(tester, AppRoutes.rulesFilterCreator);
      final localizations = AppLocalizations.of(recorder.context);

      singleEmailController.openEmailAddressDialog(EmailAddress('Carol', DelegationFixtures.carolAddress));
      await tester.pumpAndSettle();

      expect(find.text(localizations.compose_email), findsOneWidget);
      expect(find.text(localizations.quickCreatingRule), findsNothing);
    });

    testWidgets('the email address bottom sheet has no quick rule while a delegated account is shown',
        (tester) async {
      when(responsiveUtils.isScreenWithShortestSide(any)).thenReturn(true);
      addTearDown(() => when(responsiveUtils.isScreenWithShortestSide(any)).thenReturn(false));
      ActiveAccountSourceFixtures.putForThisTest(
        DelegationFixtures.session(),
        shownAccountId: DelegationFixtures.bobAccountId,
      );
      singleEmailController.onInit();
      final recorder = await RouteArgumentsRecorder.pump(tester, AppRoutes.rulesFilterCreator);
      final localizations = AppLocalizations.of(recorder.context);

      singleEmailController.openEmailAddressDialog(EmailAddress('Carol', DelegationFixtures.carolAddress));
      await tester.pumpAndSettle();

      expect(find.byType(EmailAddressBottomSheetBuilder), findsOneWidget);
      expect(find.text(localizations.compose_email), findsOneWidget);
      expect(find.text(localizations.quickCreatingRule), findsNothing);
    });
  });
}

class _TestView extends GetWidget<SingleEmailController> {
  const _TestView();

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}