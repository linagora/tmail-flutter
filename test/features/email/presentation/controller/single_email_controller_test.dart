import 'package:core/core.dart';
import 'package:core/utils/application_manager.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/toast/app_toast_manager.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/email/domain/state/view_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachments_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/export_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/store_opened_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/view_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/email_supervisor_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:uuid/uuid.dart';

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
  MockSpec<ViewAttachmentForWebInteractor>(),
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
  MockSpec<ApplicationManager>(),
  MockSpec<AppToastManager>(),
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
  final viewAttachmentForWebInteractor = MockViewAttachmentForWebInteractor();
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
  final applicationManager = MockApplicationManager();
  final appToastManager = MockAppToastManager();

  late SingleEmailController singleEmailController = SingleEmailController(
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
    viewAttachmentForWebInteractor,
    printEmailInteractor,
  );

  final testAccountId = AccountId(Id('123'));
  final google = Uri.parse('https://www.google.com');
  final testSession =
      Session({}, {}, {}, UserName('data'), google, google, google, google, State('1'));
  const testTaskId = 'taskId';
  final testDownloadTaskId = DownloadTaskId(testTaskId);
  final testBytes = Uint8List(123);

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
    Get.put<ApplicationManager>(applicationManager);
    Get.put<AppToastManager>(appToastManager);

    when(mailboxDashboardController.accountId).thenReturn(Rxn(testAccountId));
    when(uuid.v4()).thenReturn(testTaskId);
  });

  group('single email controller', () {
    test(
      'should call execute on ViewAttachmentForWebInteractor '
      'when viewAttachmentForWeb is called',
      () {
        // arrange
        when(mailboxDashboardController.sessionCurrent).thenReturn(testSession);
        final testAttachment = Attachment();

        // act
        singleEmailController.viewAttachmentForWeb(testAttachment);

        // assert
        verify(viewAttachmentForWebInteractor.execute(
          any,
          testAttachment,
          testAccountId,
          any,
          any,
        )).called(1);
      },
    );

    test(
      'should trigger mailboxDashBoardController.deleteDownloadTask & downloadManager.openDownloadedFileWeb'
      'when attachment mime type is pdf',
      () async {
        // arrange
        const attachmentName = 'test_name.pdf';
        final testAttachment = Attachment(
          type: MediaType('application', 'pdf'),
          name: attachmentName);
        when(mailboxDashboardController.sessionCurrent).thenReturn(testSession);
        when(viewAttachmentForWebInteractor.execute(
          testDownloadTaskId,
          testAttachment,
          testAccountId,
          any,
          any,
        )).thenAnswer((_) => Stream.value(
              right(ViewAttachmentForWebSuccess(
                testDownloadTaskId,
                testAttachment,
                testBytes,
              )),
            ));

        // act
        singleEmailController.viewAttachmentForWeb(testAttachment);

        // assert
        await untilCalled(mailboxDashboardController.deleteDownloadTask(any));
        verify(mailboxDashboardController.deleteDownloadTask(testDownloadTaskId))
            .called(1);
        await untilCalled(downloadManager.openDownloadedFileWeb(any, any, any));
        verify(downloadManager.openDownloadedFileWeb(
          testBytes,
          Constant.pdfMimeType,
          attachmentName,
        )).called(1);
      },
    );

    test(
      'should trigger mailboxDashBoardController.deleteDownloadTask & downloadManager.createAnchorElementDownloadFileWeb'
      'when attachment mime type is not pdf',
      () async {
        // arrange
        const testFileName = 'test_file.txt';
        final testAttachment = Attachment(name: testFileName);
        when(mailboxDashboardController.sessionCurrent).thenReturn(testSession);
        when(viewAttachmentForWebInteractor.execute(
          testDownloadTaskId,
          testAttachment,
          testAccountId,
          any,
          any,
        )).thenAnswer((_) => Stream.value(
              right(ViewAttachmentForWebSuccess(
                testDownloadTaskId,
                testAttachment,
                testBytes,
              )),
            ));

        // act
        singleEmailController.viewAttachmentForWeb(testAttachment);

        // assert
        await untilCalled(mailboxDashboardController.deleteDownloadTask(any));
        verify(mailboxDashboardController.deleteDownloadTask(testDownloadTaskId))
            .called(1);
        await untilCalled(
          downloadManager.createAnchorElementDownloadFileWeb(any, any),
        );
        verify(downloadManager.createAnchorElementDownloadFileWeb(
          testBytes,
          testFileName,
        )).called(1);
      },
    );
  });
}
