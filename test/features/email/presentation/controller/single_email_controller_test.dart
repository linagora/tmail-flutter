import 'dart:ui';

import 'package:core/core.dart';
import 'package:core/utils/application_manager.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/calendar_event_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_accept_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_accept_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_calendar_event_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/calendar_event_accept_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/maybe_calendar_event_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/calendar_event_reject_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachments_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/export_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/store_event_attendance_status_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/store_opened_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/email_supervisor_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/model/blob_calendar_event.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../../fixtures/email_fixtures.dart';
import 'single_email_controller_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<GetEmailContentInteractor>(),
  MockSpec<MarkAsEmailReadInteractor>(),
  MockSpec<DownloadAttachmentsInteractor>(),
  MockSpec<DeviceManager>(),
  MockSpec<ExportAttachmentInteractor>(),
  MockSpec<MoveToMailboxInteractor>(),
  MockSpec<MarkAsStarEmailInteractor>(),
  MockSpec<DownloadAttachmentForWebInteractor>(),
  MockSpec<GetAllIdentitiesInteractor>(),
  MockSpec<StoreOpenedEmailInteractor>(),
  MockSpec<MailboxDashBoardController>(fallbackGenerators: fallbackGenerators),
  MockSpec<EmailSupervisorController>(fallbackGenerators: fallbackGenerators),
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
  MockSpec<StoreEventAttendanceStatusInteractor>(),
  MockSpec<PrintUtils>(),
  MockSpec<ApplicationManager>(),
  MockSpec<ToastManager>(),
  MockSpec<TwakeAppManager>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final getEmailContentInteractor = MockGetEmailContentInteractor();
  final markAsEmailReadInteractor = MockMarkAsEmailReadInteractor();
  final downloadAttachmentsInteractor = MockDownloadAttachmentsInteractor();
  final deviceManager = MockDeviceManager();
  final exportAttachmentInteractor = MockExportAttachmentInteractor();
  final moveToMailboxInteractor = MockMoveToMailboxInteractor();
  final markAsStarEmailInteractor = MockMarkAsStarEmailInteractor();
  final downloadAttachmentForWebInteractor =
      MockDownloadAttachmentForWebInteractor();
  final getAllIdentitiesInteractor = MockGetAllIdentitiesInteractor();
  final storeOpenedEmailInteractor = MockStoreOpenedEmailInteractor();
  final mailboxDashboardController = MockMailboxDashBoardController();
  final emailSupervisorController = MockEmailSupervisorController();
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
  final storeEventAttendanceStatusInteractor = MockStoreEventAttendanceStatusInteractor();
  final printUtils = MockPrintUtils();
  final applicationManager = MockApplicationManager();
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
    Get.put<MailboxDashBoardController>(mailboxDashboardController);
    Get.put<EmailSupervisorController>(emailSupervisorController);
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
    Get.put<ApplicationManager>(applicationManager);
    Get.put<ToastManager>(mockToastManager);
    Get.put<TwakeAppManager>(mockTwakeAppManager);

    when(mailboxDashboardController.accountId).thenReturn(Rxn(testAccountId));
    when(uuid.v4()).thenReturn(testTaskId);
  });

  setUp(() {
    singleEmailController = SingleEmailController(
      getEmailContentInteractor,
      markAsEmailReadInteractor,
      downloadAttachmentsInteractor,
      deviceManager,
      exportAttachmentInteractor,
      moveToMailboxInteractor,
      markAsStarEmailInteractor,
      downloadAttachmentForWebInteractor,
      getAllIdentitiesInteractor,
      storeOpenedEmailInteractor,
      printEmailInteractor,
      storeEventAttendanceStatusInteractor,
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

      test('should call execute on AcceptCalendarEventInteractor '
      'when onCalendarEventReplyAction is called on EventActionType.yes', () async {
        // arrange
        when(mailboxDashboardController.selectedEmail).thenReturn(Rxn(null));
        when(mailboxDashboardController.emailUIAction).thenReturn(Rxn(null));
        when(mailboxDashboardController.viewState).thenReturn(Rx(Right(UIState.idle)));
        when(mailboxDashboardController.sessionCurrent).thenReturn(testSession);
        singleEmailController.onInit();
        Get.put<AcceptCalendarEventInteractor>(acceptCalendarEventInteractor);
          mailboxDashboardController.accountId.refresh();
          singleEmailController.handleSuccessViewState(
            ParseCalendarEventSuccess([
              BlobCalendarEvent(
                blobId: blobId,
                calendarEventList: [calendarEvent])]));

        // act
        singleEmailController.onCalendarEventReplyAction(EventActionType.yes, emailId);
        await untilCalled(acceptCalendarEventInteractor.execute(any, any, any, any));

        // assert
        verify(acceptCalendarEventInteractor.execute(testAccountId, {blobId}, emailId, locale.languageCode)).called(1);
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
        singleEmailController.onInit();
        Get.put<MaybeCalendarEventInteractor>(maybeCalendarEventInteractor);
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
        singleEmailController.onInit();
        Get.put<RejectCalendarEventInteractor>(rejectCalendarEventInteractor);
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

  group('StoreEventAttendanceStatusInteractor test', () {

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    });

    group('calendarEventSuccess method test', () {
      test(
        'SHOULD call execute on StoreEventAttendanceStatusInteractor\n'
        'WHEN calendarEventSuccess method is called',
      () {
        when(mailboxDashboardController.sessionCurrent).thenReturn(testSession);

        final eventAcceptedSuccess = CalendarEventAccepted(
          CalendarEventAcceptResponse(testAccountId, null),
          EmailFixtures.emailId);

        singleEmailController.calendarEventSuccess(eventAcceptedSuccess);

        verify(storeEventAttendanceStatusInteractor.execute(
          testSession,
          testAccountId,
          EmailFixtures.emailId,
          EventActionType.yes,
        )).called(1);
      });
    });

    group('onCalendarEventReplyAction method test', () {
      test(
        'SHOULD call execute on StoreEventAttendanceStatusInteractor\n'
        'WHEN onCalendarEventReplyAction is called on EventActionType.yes\n'
        'AND return success',
      () async {
        final acceptCalendarEventInteractor = MockAcceptCalendarEventInteractor();
        final blobId = Id('abc123');
        final emailId = EmailId(Id('xyz123'));
        final calendarEvent = CalendarEvent();

        when(mailboxDashboardController.sessionCurrent).thenReturn(testSession);
        when(mailboxDashboardController.selectedEmail).thenReturn(Rxn(null));
        when(mailboxDashboardController.emailUIAction).thenReturn(Rxn(null));
        when(mailboxDashboardController.viewState).thenReturn(Rx(Right(UIState.idle)));

        singleEmailController.onInit();

        Get.put<AcceptCalendarEventInteractor>(acceptCalendarEventInteractor);

        mailboxDashboardController.accountId.refresh();

        singleEmailController.handleSuccessViewState(
          ParseCalendarEventSuccess([
            BlobCalendarEvent(
              blobId: blobId,
              calendarEventList: [calendarEvent]
            )
          ])
        );

        singleEmailController.onCalendarEventReplyAction(EventActionType.yes, emailId);

        singleEmailController.calendarEventSuccess(CalendarEventAccepted(
          CalendarEventAcceptResponse(testAccountId, null),
          emailId
        ));

        await untilCalled(storeEventAttendanceStatusInteractor.execute(any, any, any, any));

        verify(storeEventAttendanceStatusInteractor.execute(
          testSession,
          testAccountId,
          emailId,
          EventActionType.yes,
        )).called(1);
      });
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
