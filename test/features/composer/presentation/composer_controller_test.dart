import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/application_manager.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/email_property.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:tmail_ui_user/features/base/before_reconnect_manager.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_save_email_to_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/download_image_as_base64_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view_web.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_mobile_tablet_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/formatting_options_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/saved_email_draft.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/transform_html_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/draggable_app_state.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/get_always_read_receipt_setting_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_always_read_receipt_setting_interactor.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_file_picker_interactor.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_image_picker_interactor.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../fixtures/account_fixtures.dart';
import '../../../fixtures/session_fixtures.dart';
import '../../../fixtures/widget_fixtures.dart';
import '../../../mocks/mock_web_view_platform.dart';
import 'composer_controller_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

class MockRichTextWebController extends Mock implements RichTextWebController {
  @override
  Rx<FormattingOptionsState> get formattingOptionsState => 
    FormattingOptionsState.disabled.obs;

  @override
  bool get isFormattingOptionsEnabled => formattingOptionsState.value == FormattingOptionsState.enabled;

  @override
  HtmlEditorController get editorController => MockHtmlEditorController();

  @override
  bool get codeViewEnabled => false;
}

class MockMailboxDashBoardController extends Mock implements MailboxDashBoardController {
  @override
  InternalFinalCallback<void> get onStart => mockControllerCallback();
  @override
  InternalFinalCallback<void> get onDelete => mockControllerCallback();

  @override
  Rxn<AccountId> get accountId => Rxn(AccountFixtures.aliceAccountId);
  @override
  Session? get sessionCurrent => SessionFixtures.aliceSession;

  @override
  Rxn<DraggableAppState> get attachmentDraggableAppState => Rxn(DraggableAppState.inActive);
  @override
  bool get isAttachmentDraggableAppActive => attachmentDraggableAppState.value == DraggableAppState.active;

  @override
  Rxn<DraggableAppState> get localFileDraggableAppState => Rxn(DraggableAppState.inActive);
  @override
  bool get isLocalFileDraggableAppActive => localFileDraggableAppState.value == DraggableAppState.active;

  @override
  Map<Role, MailboxId> get mapDefaultMailboxIdByRole => {PresentationMailbox.roleDrafts: MailboxId(Id('value'))};

  @override
  String get baseDownloadUrl => '';

  @override
  int get minInputLengthAutocomplete => AppConfig.defaultMinInputLengthAutocomplete;

  @override
  Map<MailboxId, PresentationMailbox> get mapMailboxById => {};
}

@GenerateNiceMocks([
  // Base controller mock specs
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
  MockSpec<Uuid>(),
  MockSpec<ApplicationManager>(),
  MockSpec<ToastManager>(),
  MockSpec<TwakeAppManager>(),

  // Composer controller mock specs
  MockSpec<LocalFilePickerInteractor>(),
  MockSpec<LocalImagePickerInteractor>(),
  MockSpec<GetEmailContentInteractor>(),
  MockSpec<GetAllIdentitiesInteractor>(),
  MockSpec<UploadController>(fallbackGenerators: fallbackGenerators),
  MockSpec<RemoveComposerCacheOnWebInteractor>(),
  MockSpec<SaveComposerCacheOnWebInteractor>(),
  MockSpec<DownloadImageAsBase64Interactor>(),
  MockSpec<TransformHtmlEmailContentInteractor>(),
  MockSpec<GetAlwaysReadReceiptSettingInteractor>(),
  MockSpec<CreateNewAndSendEmailInteractor>(),
  MockSpec<CreateNewAndSaveEmailToDraftsInteractor>(),
  MockSpec<PrintEmailInteractor>(),

  // Additional Getx dependencies mock specs
  MockSpec<NetworkConnectionController>(fallbackGenerators: fallbackGenerators),
  MockSpec<BeforeReconnectManager>(),
  MockSpec<RichTextMobileTabletController>(fallbackGenerators: fallbackGenerators),
  MockSpec<CacheExceptionThrower>(),

  // Additional misc dependencies mock specs
  MockSpec<HtmlEditorApi>(),
  MockSpec<HtmlEditorController>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Declaration base controller
  late MockCachingManager mockCachingManager;
  late MockLanguageCacheManager mockLanguageCacheManager;
  late MockAuthorizationInterceptors mockAuthorizationInterceptors;
  late MockDynamicUrlInterceptors mockDynamicUrlInterceptors;
  late MockDeleteCredentialInteractor mockDeleteCredentialInteractor;
  late MockLogoutOidcInteractor mockLogoutOidcInteractor;
  late MockDeleteAuthorityOidcInteractor mockDeleteAuthorityOidcInteractor;
  late MockAppToast mockAppToast;
  late MockUuid mockUuid;
  late MockApplicationManager mockApplicationManager;
  late MockToastManager mockToastManager;
  late MockTwakeAppManager mockTwakeAppManager;

  // Declaration composer controller
  late ComposerController? composerController;
  late MockLocalFilePickerInteractor mockLocalFilePickerInteractor;
  late MockLocalImagePickerInteractor mockLocalImagePickerInteractor;
  late MockGetEmailContentInteractor mockGetEmailContentInteractor;
  late MockGetAllIdentitiesInteractor mockGetAllIdentitiesInteractor;
  late MockUploadController mockUploadController;
  late MockRemoveComposerCacheOnWebInteractor mockRemoveComposerCacheOnWebInteractor;
  late MockSaveComposerCacheOnWebInteractor mockSaveComposerCacheOnWebInteractor;
  late MockDownloadImageAsBase64Interactor mockDownloadImageAsBase64Interactor;
  late MockTransformHtmlEmailContentInteractor mockTransformHtmlEmailContentInteractor;
  late MockGetAlwaysReadReceiptSettingInteractor mockGetAlwaysReadReceiptSettingInteractor;
  late MockCreateNewAndSendEmailInteractor mockCreateNewAndSendEmailInteractor;
  late MockCreateNewAndSaveEmailToDraftsInteractor mockCreateNewAndSaveEmailToDraftsInteractor;
  late MockPrintEmailInteractor mockPrintEmailInteractor;

  // Declaration Getx dependencies
  final mockMailboxDashBoardController = MockMailboxDashBoardController();
  final mockNetworkConnectionController = MockNetworkConnectionController();
  final mockBeforeReconnectManager = MockBeforeReconnectManager();
  final mockRichTextMobileTabletController = MockRichTextMobileTabletController();
  final mockRichTextWebController = MockRichTextWebController();
  final mockCacheExceptionThrower = MockCacheExceptionThrower();

  // Declaration misc dependencies
  late MockHtmlEditorApi mockHtmlEditorApi;

  setUp(() {
    Get.testMode = true;
    // Mock base controller
    mockCachingManager = MockCachingManager();
    mockLanguageCacheManager = MockLanguageCacheManager();
    mockAuthorizationInterceptors = MockAuthorizationInterceptors();
    mockDynamicUrlInterceptors = MockDynamicUrlInterceptors();
    mockDeleteCredentialInteractor = MockDeleteCredentialInteractor();
    mockLogoutOidcInteractor = MockLogoutOidcInteractor();
    mockDeleteAuthorityOidcInteractor = MockDeleteAuthorityOidcInteractor();
    mockAppToast = MockAppToast();
    mockUuid = MockUuid();
    mockApplicationManager = MockApplicationManager();
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
    Get.put<ImagePaths>(ImagePaths());
    Get.put<ResponsiveUtils>(ResponsiveUtils());
    Get.put<Uuid>(mockUuid);
    Get.put<ApplicationManager>(mockApplicationManager);
    Get.put<ToastManager>(mockToastManager);
    Get.put<TwakeAppManager>(mockTwakeAppManager);

    // Mock Getx controllers
    Get.put<MailboxDashBoardController>(mockMailboxDashBoardController);
    Get.put<NetworkConnectionController>(mockNetworkConnectionController);
    Get.put<BeforeReconnectManager>(mockBeforeReconnectManager);
    Get.put<RichTextMobileTabletController>(mockRichTextMobileTabletController);
    Get.put<CacheExceptionThrower>(mockCacheExceptionThrower);

    // Mock composer controller
    mockLocalFilePickerInteractor = MockLocalFilePickerInteractor();
    mockLocalImagePickerInteractor = MockLocalImagePickerInteractor();
    mockGetEmailContentInteractor = MockGetEmailContentInteractor();
    mockGetAllIdentitiesInteractor = MockGetAllIdentitiesInteractor();
    mockUploadController = MockUploadController();
    mockRemoveComposerCacheOnWebInteractor = MockRemoveComposerCacheOnWebInteractor();
    mockSaveComposerCacheOnWebInteractor = MockSaveComposerCacheOnWebInteractor();
    mockDownloadImageAsBase64Interactor = MockDownloadImageAsBase64Interactor();
    mockTransformHtmlEmailContentInteractor = MockTransformHtmlEmailContentInteractor();
    mockGetAlwaysReadReceiptSettingInteractor = MockGetAlwaysReadReceiptSettingInteractor();
    mockCreateNewAndSendEmailInteractor = MockCreateNewAndSendEmailInteractor();
    mockCreateNewAndSaveEmailToDraftsInteractor = MockCreateNewAndSaveEmailToDraftsInteractor();
    mockPrintEmailInteractor = MockPrintEmailInteractor();

    composerController = ComposerController(
      mockLocalFilePickerInteractor,
      mockLocalImagePickerInteractor,
      mockGetEmailContentInteractor,
      mockGetAllIdentitiesInteractor,
      mockUploadController,
      mockRemoveComposerCacheOnWebInteractor,
      mockSaveComposerCacheOnWebInteractor,
      mockDownloadImageAsBase64Interactor,
      mockTransformHtmlEmailContentInteractor,
      mockGetAlwaysReadReceiptSettingInteractor,
      mockCreateNewAndSendEmailInteractor,
      mockCreateNewAndSaveEmailToDraftsInteractor,
      mockPrintEmailInteractor,
    );

    mockHtmlEditorApi = MockHtmlEditorApi();
  });

  tearDown(() {
    Get.reset();
    composerController = null;
  });
  
  group('ComposerController test:', () {
    group('hash draft email test:', () {
      const emailContent = 'some email content';
      const emailSubject = 'some email subject';
      final toRecipient = EmailAddress('to', 'to@linagora.com');
      final ccRecipient = EmailAddress('cc', 'cc@linagora.com');
      final bccRecipient = EmailAddress('bcc', 'bcc@linagora.com');
      final replyToRecipient = EmailAddress('replyTo', 'replyTo@linagora.com');
      final identity = Identity();
      final attachment = Attachment();
      const alwaysReadReceiptEnabled = true;

      group('email action type is EmailActionType.compose:', () {
        setUp(() {
          composerController?.composerArguments.value = ComposerArguments(
          emailActionType: EmailActionType.compose);
        });

        test(
          'should update _savedEmailDraftHash '
          'when there is a new view state '
          'and the state is GetAlwaysReadReceiptSettingSuccess',
        () async {
          // arrange
          composerController?.richTextMobileTabletController = mockRichTextMobileTabletController;
          when(mockRichTextMobileTabletController.htmlEditorApi).thenReturn(
            mockHtmlEditorApi);

          when(mockHtmlEditorApi.getText()).thenAnswer((_) async => emailContent);
          composerController?.subjectEmail.value = emailSubject;
          composerController?.listToEmailAddress = [toRecipient];
          composerController?.listCcEmailAddress = [ccRecipient];
          composerController?.listBccEmailAddress = [bccRecipient];
          composerController?.listReplyToEmailAddress = [replyToRecipient];
          composerController?.identitySelected.value = identity;
          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);
          final state = GetAlwaysReadReceiptSettingSuccess(
            alwaysReadReceiptEnabled: alwaysReadReceiptEnabled);

          final savedEmailDraft = SavedEmailDraft(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: identity,
            attachments: [attachment],
            hasReadReceipt: alwaysReadReceiptEnabled
          );
          
          // act
          composerController?.handleSuccessViewState(state);
          await untilCalled(mockHtmlEditorApi.getText());
          
          // assert
          expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);
        });

        test(
          'should update _savedEmailDraftHash '
          'when there is a new view state '
          'and the state is GetAlwaysReadReceiptSettingFailure',
        () async {
          // arrange
          composerController?.richTextMobileTabletController = mockRichTextMobileTabletController;
          when(mockRichTextMobileTabletController.htmlEditorApi).thenReturn(
            mockHtmlEditorApi);
          
          when(mockHtmlEditorApi.getText()).thenAnswer((_) async => emailContent);
          composerController?.subjectEmail.value = emailSubject;
          composerController?.listToEmailAddress = [toRecipient];
          composerController?.listCcEmailAddress = [ccRecipient];
          composerController?.listBccEmailAddress = [bccRecipient];
          composerController?.listReplyToEmailAddress = [replyToRecipient];
          composerController?.identitySelected.value = identity;
          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);
          final state = GetAlwaysReadReceiptSettingFailure(Exception());

          final savedEmailDraft = SavedEmailDraft(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: identity,
            attachments: [attachment],
            hasReadReceipt: false
          );
          
          // act
          composerController?.handleFailureViewState(state);
          await untilCalled(mockHtmlEditorApi.getText());
          
          // assert
          expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);
        });

        test(
          'should update _savedEmailDraftHash '
          'when _initIdentities is called '
          'and listFromIdentities is not empty '
          'and selectedIdentity is available',
        () async {
          // arrange
          PlatformInfo.isTestingForWeb = true;

          final selectedIdentity = Identity(id: IdentityId(Id('alice')));

          composerController = ComposerController(
            mockLocalFilePickerInteractor,
            mockLocalImagePickerInteractor,
            mockGetEmailContentInteractor,
            mockGetAllIdentitiesInteractor,
            mockUploadController,
            mockRemoveComposerCacheOnWebInteractor,
            mockSaveComposerCacheOnWebInteractor,
            mockDownloadImageAsBase64Interactor,
            mockTransformHtmlEmailContentInteractor,
            mockGetAlwaysReadReceiptSettingInteractor,
            mockCreateNewAndSendEmailInteractor,
            mockCreateNewAndSaveEmailToDraftsInteractor,
            mockPrintEmailInteractor,
            composerArgs: ComposerArguments(
              selectedIdentityId: selectedIdentity.id,
              identities: [selectedIdentity],
            ),
          );

          composerController?.onChangeTextEditorWeb(emailContent);
          composerController?.subjectEmail.value = emailSubject;
          composerController?.listToEmailAddress = [toRecipient];
          composerController?.listCcEmailAddress = [ccRecipient];
          composerController?.listBccEmailAddress = [bccRecipient];
          composerController?.listReplyToEmailAddress = [replyToRecipient];
          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);


          final savedEmailDraft = SavedEmailDraft(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: selectedIdentity,
            attachments: [attachment],
            hasReadReceipt: false
          );
          
          // act
          composerController?.onReady();
          await Future.delayed(Duration.zero);
          
          // assert
          expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);

          // tear down
          PlatformInfo.isTestingForWeb = false;
        });

        test(
          'should update _savedEmailDraftHash '
          'when _initIdentities is called '
          'and listFromIdentities is not empty '
          'and selectedIdentity is not available',
        () async {
          // arrange
          PlatformInfo.isTestingForWeb = true;

          composerController = ComposerController(
            mockLocalFilePickerInteractor,
            mockLocalImagePickerInteractor,
            mockGetEmailContentInteractor,
            mockGetAllIdentitiesInteractor,
            mockUploadController,
            mockRemoveComposerCacheOnWebInteractor,
            mockSaveComposerCacheOnWebInteractor,
            mockDownloadImageAsBase64Interactor,
            mockTransformHtmlEmailContentInteractor,
            mockGetAlwaysReadReceiptSettingInteractor,
            mockCreateNewAndSendEmailInteractor,
            mockCreateNewAndSaveEmailToDraftsInteractor,
            mockPrintEmailInteractor,
            composerArgs: ComposerArguments(identities: [identity]),
          );

          composerController?.onChangeTextEditorWeb(emailContent);
          composerController?.subjectEmail.value = emailSubject;
          composerController?.listToEmailAddress = [toRecipient];
          composerController?.listCcEmailAddress = [ccRecipient];
          composerController?.listBccEmailAddress = [bccRecipient];
          composerController?.listReplyToEmailAddress = [replyToRecipient];
          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);

          final savedEmailDraft = SavedEmailDraft(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: identity,
            attachments: [attachment],
            hasReadReceipt: false
          );
          
          // act
          composerController?.onReady();
          await Future.delayed(Duration.zero);
          
          // assert
          expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);

          // tear down
          PlatformInfo.isTestingForWeb = false;
        });

        test(
          'should update _savedEmailDraftHash '
          'when _initIdentities is called '
          'and listFromIdentities is empty '
          'and selectedIdentity is available',
        () async {
          // arrange
          PlatformInfo.isTestingForWeb = true;

          final selectedIdentity = Identity(
            id: IdentityId(Id('alice')),
            mayDelete: true,
          );

          composerController = ComposerController(
            mockLocalFilePickerInteractor,
            mockLocalImagePickerInteractor,
            mockGetEmailContentInteractor,
            mockGetAllIdentitiesInteractor,
            mockUploadController,
            mockRemoveComposerCacheOnWebInteractor,
            mockSaveComposerCacheOnWebInteractor,
            mockDownloadImageAsBase64Interactor,
            mockTransformHtmlEmailContentInteractor,
            mockGetAlwaysReadReceiptSettingInteractor,
            mockCreateNewAndSendEmailInteractor,
            mockCreateNewAndSaveEmailToDraftsInteractor,
            mockPrintEmailInteractor,
            composerArgs: ComposerArguments(selectedIdentityId: selectedIdentity.id),
          );

          composerController?.onChangeTextEditorWeb(emailContent);
          composerController?.subjectEmail.value = emailSubject;
          composerController?.listToEmailAddress = [toRecipient];
          composerController?.listCcEmailAddress = [ccRecipient];
          composerController?.listBccEmailAddress = [bccRecipient];
          composerController?.listReplyToEmailAddress = [replyToRecipient];
          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);

          when(mockGetAllIdentitiesInteractor.execute(any, any)).thenAnswer(
            (_) => Stream.value(
              Right(GetAllIdentitiesSuccess([selectedIdentity], null))));

          final savedEmailDraft = SavedEmailDraft(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: selectedIdentity,
            attachments: [attachment],
            hasReadReceipt: false
          );
          
          // act
          composerController?.onReady();
          await Future.delayed(Duration.zero);
          
          // assert
          expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);

          // tear down
          PlatformInfo.isTestingForWeb = false;
        });

        test(
          'should update _savedEmailDraftHash '
          'when _initIdentities is called '
          'and listFromIdentities is empty '
          'and selectedIdentity is not available',
        () async {
          // arrange
          PlatformInfo.isTestingForWeb = true;

          composerController = ComposerController(
            mockLocalFilePickerInteractor,
            mockLocalImagePickerInteractor,
            mockGetEmailContentInteractor,
            mockGetAllIdentitiesInteractor,
            mockUploadController,
            mockRemoveComposerCacheOnWebInteractor,
            mockSaveComposerCacheOnWebInteractor,
            mockDownloadImageAsBase64Interactor,
            mockTransformHtmlEmailContentInteractor,
            mockGetAlwaysReadReceiptSettingInteractor,
            mockCreateNewAndSendEmailInteractor,
            mockCreateNewAndSaveEmailToDraftsInteractor,
            mockPrintEmailInteractor,
            composerArgs: ComposerArguments(),
          );

          composerController?.onChangeTextEditorWeb(emailContent);
          composerController?.subjectEmail.value = emailSubject;
          composerController?.listToEmailAddress = [toRecipient];
          composerController?.listCcEmailAddress = [ccRecipient];
          composerController?.listBccEmailAddress = [bccRecipient];
          composerController?.listReplyToEmailAddress = [replyToRecipient];
          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);

          final identity = Identity(
            id: IdentityId(Id('alice')),
            mayDelete: true);
          when(mockGetAllIdentitiesInteractor.execute(any, any)).thenAnswer(
            (_) => Stream.value(
              Right(GetAllIdentitiesSuccess([identity], null))));

          final savedEmailDraft = SavedEmailDraft(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: identity,
            attachments: [attachment],
            hasReadReceipt: false
          );
          
          // act
          composerController?.onReady();
          await Future.delayed(Duration.zero);
          
          // assert
          expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);

          // tear down
          PlatformInfo.isTestingForWeb = false;
        });

        testWidgets(
          'should update _savedEmailDraftHash '
          'when user click save draft button '
          'and SaveEmailAsDraftsSuccess is returned',
        (tester) async {
          await tester.runAsync(() async {
            // arrange
            PlatformInfo.isTestingForWeb = true;
            InAppWebViewPlatform.instance = MockWebViewPlatform();

            when(mockUploadController.uploadInlineViewState).thenReturn(
              Rx(Right(UIState.idle)));
            when(mockUploadController.listUploadAttachments).thenReturn(
              RxList<UploadFileState>());
            
            Get.put(composerController!);
            composerController?.richTextWebController = mockRichTextWebController;
            
            composerController?.onChangeTextEditorWeb(emailContent);
            composerController?.subjectEmail.value = emailSubject;
            composerController?.listToEmailAddress = [toRecipient];
            composerController?.listCcEmailAddress = [ccRecipient];
            composerController?.listBccEmailAddress = [bccRecipient];
            composerController?.listReplyToEmailAddress = [replyToRecipient];
            when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);

            final selectedIdentity = Identity(id: IdentityId(Id('alice')));
            composerController?.identitySelected.value = selectedIdentity;
            composerController?.composerArguments.value = ComposerArguments();
            when(
              mockCreateNewAndSaveEmailToDraftsInteractor.execute(
                createEmailRequest: anyNamed('createEmailRequest'),
                cancelToken: anyNamed('cancelToken')))
              .thenAnswer((_) => Stream.value(
                Right(SaveEmailAsDraftsSuccess(EmailId(Id('123')), null))));

            final savedEmailDraft = SavedEmailDraft(
              content: emailContent,
              subject: emailSubject,
              toRecipients: {toRecipient},
              ccRecipients: {ccRecipient},
              bccRecipients: {bccRecipient},
              replyToRecipients: {replyToRecipient},
              identity: selectedIdentity,
              attachments: [attachment],
              hasReadReceipt: false
            );

            await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
              child: const Stack(children: [ComposerView()])));
            await tester.pump();
            
            // act
            final saveAsDraftButton = find.ancestor(
              of: find.byType(InkWell),
              matching: find.byWidgetPredicate(
                (widget) => widget is TMailButtonWidget
                  && widget.icon == ImagePaths().icSaveToDraft));
            await tester.tap(saveAsDraftButton);
            await tester.pump();
            await untilCalled(
              mockCreateNewAndSaveEmailToDraftsInteractor.execute(
                createEmailRequest: anyNamed('createEmailRequest'),
                cancelToken: anyNamed('cancelToken')));
            
            // assert
            expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);

            // tear down
            PlatformInfo.isTestingForWeb = false;
          });
        });

        testWidgets(
          'should update _savedEmailDraftHash '
          'when user click save draft button '
          'and UpdateEmailDraftsSuccess is returned',
        (tester) async {
          await tester.runAsync(() async {
            // arrange
            PlatformInfo.isTestingForWeb = true;
            InAppWebViewPlatform.instance = MockWebViewPlatform();

            when(mockUploadController.uploadInlineViewState).thenReturn(
              Rx(Right(UIState.idle)));
            when(mockUploadController.listUploadAttachments).thenReturn(
              RxList<UploadFileState>());
            
            Get.put(composerController!);
            composerController?.richTextWebController = mockRichTextWebController;
            
            composerController?.onChangeTextEditorWeb(emailContent);
            composerController?.subjectEmail.value = emailSubject;
            composerController?.listToEmailAddress = [toRecipient];
            composerController?.listCcEmailAddress = [ccRecipient];
            composerController?.listBccEmailAddress = [bccRecipient];
            composerController?.listReplyToEmailAddress = [replyToRecipient];
            when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);

            final selectedIdentity = Identity(id: IdentityId(Id('alice')));
            composerController?.identitySelected.value = selectedIdentity;
            composerController?.composerArguments.value = ComposerArguments();
            when(
              mockCreateNewAndSaveEmailToDraftsInteractor.execute(
                createEmailRequest: anyNamed('createEmailRequest'),
                cancelToken: anyNamed('cancelToken')))
              .thenAnswer((_) => Stream.value(
                Right(UpdateEmailDraftsSuccess(EmailId(Id('123'))))));

            final savedEmailDraft = SavedEmailDraft(
              content: emailContent,
              subject: emailSubject,
              toRecipients: {toRecipient},
              ccRecipients: {ccRecipient},
              bccRecipients: {bccRecipient},
              replyToRecipients: {replyToRecipient},
              identity: selectedIdentity,
              attachments: [attachment],
              hasReadReceipt: false
            );

            await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
              child: const Stack(children: [ComposerView()])));
            await tester.pump();
            
            // act
            final saveAsDraftButton = find.ancestor(
              of: find.byType(InkWell),
              matching: find.byWidgetPredicate(
                (widget) => widget is TMailButtonWidget
                  && widget.icon == ImagePaths().icSaveToDraft));
            await tester.tap(saveAsDraftButton);
            await tester.pump();
            await untilCalled(
              mockCreateNewAndSaveEmailToDraftsInteractor.execute(
                createEmailRequest: anyNamed('createEmailRequest'),
                cancelToken: anyNamed('cancelToken')));
            
            // assert
            expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);

            // tear down
            PlatformInfo.isTestingForWeb = false;
          });
        });
      });

      group('email action type is EmailActionType.editDraft:', () {
        setUp(() {
          composerController?.composerArguments.value = ComposerArguments(
          emailActionType: EmailActionType.editDraft);
        });

        test(
          'should update _savedEmailDraftHash '
          'when there is a new view state '
          'and the state is GetAlwaysReadReceiptSettingSuccess',
        () async {
          // arrange
          composerController?.richTextMobileTabletController = mockRichTextMobileTabletController;
          when(mockRichTextMobileTabletController.htmlEditorApi).thenReturn(
            mockHtmlEditorApi);
          
          when(mockHtmlEditorApi.getText()).thenAnswer((_) async => emailContent);
          composerController?.subjectEmail.value = emailSubject;
          composerController?.listToEmailAddress = [toRecipient];
          composerController?.listCcEmailAddress = [ccRecipient];
          composerController?.listBccEmailAddress = [bccRecipient];
          composerController?.listReplyToEmailAddress = [replyToRecipient];
          composerController?.identitySelected.value = identity;
          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);

          const alwaysReadReceiptEnabled = true;
          final state = GetAlwaysReadReceiptSettingSuccess(
            alwaysReadReceiptEnabled: alwaysReadReceiptEnabled);

          final savedEmailDraft = SavedEmailDraft(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: identity,
            attachments: [attachment],
            hasReadReceipt: alwaysReadReceiptEnabled
          );
          
          // act
          composerController?.handleSuccessViewState(state);
          await untilCalled(mockHtmlEditorApi.getText());
          
          // assert
          expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);
        });

        test(
          'should update _savedEmailDraftHash '
          'when there is a new view state '
          'and the state is GetAlwaysReadReceiptSettingFailure',
        () async {
          // arrange
          composerController?.richTextMobileTabletController = mockRichTextMobileTabletController;
          when(mockRichTextMobileTabletController.htmlEditorApi).thenReturn(
            mockHtmlEditorApi);
          
          when(mockHtmlEditorApi.getText()).thenAnswer((_) async => emailContent);
          composerController?.subjectEmail.value = emailSubject;
          composerController?.listToEmailAddress = [toRecipient];
          composerController?.listCcEmailAddress = [ccRecipient];
          composerController?.listBccEmailAddress = [bccRecipient];
          composerController?.listReplyToEmailAddress = [replyToRecipient];
          composerController?.identitySelected.value = identity;
          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);

          final state = GetAlwaysReadReceiptSettingFailure(Exception());

          final savedEmailDraft = SavedEmailDraft(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: identity,
            attachments: [attachment],
            hasReadReceipt: false
          );
          
          // act
          composerController?.handleFailureViewState(state);
          await untilCalled(mockHtmlEditorApi.getText());
          
          // assert
          expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);
        });

        test(
          'should update _savedEmailDraftHash '
          'when _initIdentities is called '
          'and listFromIdentities is not empty '
          'and selectedIdentity is available',
        () async {
          // arrange
          PlatformInfo.isTestingForWeb = true;

          final selectedIdentity = Identity(id: IdentityId(Id('alice')));

          composerController = ComposerController(
            mockLocalFilePickerInteractor,
            mockLocalImagePickerInteractor,
            mockGetEmailContentInteractor,
            mockGetAllIdentitiesInteractor,
            mockUploadController,
            mockRemoveComposerCacheOnWebInteractor,
            mockSaveComposerCacheOnWebInteractor,
            mockDownloadImageAsBase64Interactor,
            mockTransformHtmlEmailContentInteractor,
            mockGetAlwaysReadReceiptSettingInteractor,
            mockCreateNewAndSendEmailInteractor,
            mockCreateNewAndSaveEmailToDraftsInteractor,
            mockPrintEmailInteractor,
            composerArgs: ComposerArguments(
                emailActionType: EmailActionType.editDraft,
                emailContents: emailContent,
                presentationEmail: PresentationEmail(
                  id: EmailId(Id('some-email-id')),
                  subject: emailSubject,
                  to: {toRecipient},
                  cc: {ccRecipient},
                  bcc: {bccRecipient},
                  mailboxContain: PresentationMailbox(
                    MailboxId(Id('some-mailbox-id')),
                    role: PresentationMailbox.roleJunk,
                  ),
                ),
                selectedIdentityId: selectedIdentity.id,
                identities: [selectedIdentity],
            ),
          );

          composerController?.onChangeTextEditorWeb(emailContent);

          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);

          final savedEmailDraft = SavedEmailDraft(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: selectedIdentity,
            attachments: [attachment],
            hasReadReceipt: false
          );
          
          // act
          composerController?.onReady();
          await Future.delayed(Duration.zero);
          
          // assert
          expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);

          // tear down
          PlatformInfo.isTestingForWeb = false;
        });

        test(
          'should update _savedEmailDraftHash '
          'when _initIdentities is called '
          'and listFromIdentities is not empty '
          'and selectedIdentity is not available',
        () async {
          // arrange
          PlatformInfo.isTestingForWeb = true;

          final identity = Identity(id: IdentityId(Id('alice')));

          composerController = ComposerController(
            mockLocalFilePickerInteractor,
            mockLocalImagePickerInteractor,
            mockGetEmailContentInteractor,
            mockGetAllIdentitiesInteractor,
            mockUploadController,
            mockRemoveComposerCacheOnWebInteractor,
            mockSaveComposerCacheOnWebInteractor,
            mockDownloadImageAsBase64Interactor,
            mockTransformHtmlEmailContentInteractor,
            mockGetAlwaysReadReceiptSettingInteractor,
            mockCreateNewAndSendEmailInteractor,
            mockCreateNewAndSaveEmailToDraftsInteractor,
            mockPrintEmailInteractor,
            composerArgs: ComposerArguments(
              emailActionType: EmailActionType.editDraft,
              emailContents: emailContent,
              presentationEmail: PresentationEmail(
                id: EmailId(Id('some-email-id')),
                subject: emailSubject,
                to: {toRecipient},
                cc: {ccRecipient},
                bcc: {bccRecipient},
                replyTo: {replyToRecipient},
                mailboxContain: PresentationMailbox(
                  MailboxId(Id('some-mailbox-id')),
                  role: PresentationMailbox.roleJunk,
                ),
              ),
              identities: [identity],
            ),
          );

          composerController?.onChangeTextEditorWeb(emailContent);

          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);

          final savedEmailDraft = SavedEmailDraft(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: identity,
            attachments: [attachment],
            hasReadReceipt: false
          );
          
          // act
          composerController?.onReady();
          await Future.delayed(Duration.zero);
          
          // assert
          expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);

          // tear down
          PlatformInfo.isTestingForWeb = false;
        });

        test(
          'should update _savedEmailDraftHash '
          'when _initIdentities is called '
          'and listFromIdentities is empty '
          'and selectedIdentity is available',
        () async {
          // arrange
          PlatformInfo.isTestingForWeb = true;

          final selectedIdentity = Identity(
            id: IdentityId(Id('alice')),
            mayDelete: true,
          );

          composerController = ComposerController(
            mockLocalFilePickerInteractor,
            mockLocalImagePickerInteractor,
            mockGetEmailContentInteractor,
            mockGetAllIdentitiesInteractor,
            mockUploadController,
            mockRemoveComposerCacheOnWebInteractor,
            mockSaveComposerCacheOnWebInteractor,
            mockDownloadImageAsBase64Interactor,
            mockTransformHtmlEmailContentInteractor,
            mockGetAlwaysReadReceiptSettingInteractor,
            mockCreateNewAndSendEmailInteractor,
            mockCreateNewAndSaveEmailToDraftsInteractor,
            mockPrintEmailInteractor,
            composerArgs: ComposerArguments(
              emailActionType: EmailActionType.editDraft,
              emailContents: emailContent,
              presentationEmail: PresentationEmail(
                id: EmailId(Id('some-email-id')),
                subject: emailSubject,
                to: {toRecipient},
                cc: {ccRecipient},
                bcc: {bccRecipient},
                replyTo: {replyToRecipient},
                mailboxContain: PresentationMailbox(
                  MailboxId(Id('some-mailbox-id')),
                  role: PresentationMailbox.roleJunk,
                ),
              ),
              selectedIdentityId: selectedIdentity.id,
            ),
          );

          composerController?.onChangeTextEditorWeb(emailContent);

          when(mockGetAllIdentitiesInteractor.execute(any, any)).thenAnswer(
            (_) => Stream.value(
              Right(GetAllIdentitiesSuccess([selectedIdentity], null))));

          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);

          final savedEmailDraft = SavedEmailDraft(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: selectedIdentity,
            attachments: [attachment],
            hasReadReceipt: false
          );
          
          // act
          composerController?.onReady();
          await Future.delayed(Duration.zero);
          
          // assert
          expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);

          // tear down
          PlatformInfo.isTestingForWeb = false;
        });

        test(
          'should update _savedEmailDraftHash '
          'when _initIdentities is called '
          'and listFromIdentities is empty '
          'and selectedIdentity is not available',
        () async {
          // arrange
          PlatformInfo.isTestingForWeb = true;

          final identity = Identity(
            id: IdentityId(Id('alice')),
            mayDelete: true,
          );

          composerController = ComposerController(
            mockLocalFilePickerInteractor,
            mockLocalImagePickerInteractor,
            mockGetEmailContentInteractor,
            mockGetAllIdentitiesInteractor,
            mockUploadController,
            mockRemoveComposerCacheOnWebInteractor,
            mockSaveComposerCacheOnWebInteractor,
            mockDownloadImageAsBase64Interactor,
            mockTransformHtmlEmailContentInteractor,
            mockGetAlwaysReadReceiptSettingInteractor,
            mockCreateNewAndSendEmailInteractor,
            mockCreateNewAndSaveEmailToDraftsInteractor,
            mockPrintEmailInteractor,
            composerArgs: ComposerArguments(
              emailActionType: EmailActionType.editDraft,
              emailContents: emailContent,
              presentationEmail: PresentationEmail(
                id: EmailId(Id('some-email-id')),
                subject: emailSubject,
                to: {toRecipient},
                cc: {ccRecipient},
                bcc: {bccRecipient},
                replyTo: {replyToRecipient},
                mailboxContain: PresentationMailbox(
                  MailboxId(Id('some-mailbox-id')),
                  role: PresentationMailbox.roleJunk,
                ),
              ),
            ),
          );

          composerController?.onChangeTextEditorWeb(emailContent);

          when(mockGetAllIdentitiesInteractor.execute(any, any)).thenAnswer(
            (_) => Stream.value(
              Right(GetAllIdentitiesSuccess([identity], null))));

          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);

          final savedEmailDraft = SavedEmailDraft(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: identity,
            attachments: [attachment],
            hasReadReceipt: false
          );
          
          // act
          composerController?.onReady();
          await Future.delayed(Duration.zero);
          
          // assert
          expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);

          // tear down
          PlatformInfo.isTestingForWeb = false;
        });

        testWidgets(
          'should update _savedEmailDraftHash '
          'when user click save draft button '
          'and SaveEmailAsDraftsSuccess is returned',
        (tester) async {
          await tester.runAsync(() async {
            // arrange
            PlatformInfo.isTestingForWeb = true;
            InAppWebViewPlatform.instance = MockWebViewPlatform();

            when(mockUploadController.uploadInlineViewState).thenReturn(
              Rx(Right(UIState.idle)));
            when(mockUploadController.listUploadAttachments).thenReturn(
              RxList<UploadFileState>());
            
            Get.put(composerController!);
            composerController?.richTextWebController = mockRichTextWebController;

            composerController?.onChangeTextEditorWeb(emailContent);
            composerController?.subjectEmail.value = emailSubject;
            composerController?.listToEmailAddress = [toRecipient];
            composerController?.listCcEmailAddress = [ccRecipient];
            composerController?.listBccEmailAddress = [bccRecipient];
            composerController?.listReplyToEmailAddress = [replyToRecipient];
            final selectedIdentity = Identity(id: IdentityId(Id('alice')));
            composerController?.identitySelected.value = selectedIdentity;
            when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);

            composerController?.composerArguments.value = ComposerArguments(
              emailActionType: EmailActionType.editDraft);
            when(
              mockCreateNewAndSaveEmailToDraftsInteractor.execute(
                createEmailRequest: anyNamed('createEmailRequest'),
                cancelToken: anyNamed('cancelToken')))
              .thenAnswer((_) => Stream.value(
                Right(SaveEmailAsDraftsSuccess(EmailId(Id('123')), null))));

            final savedEmailDraft = SavedEmailDraft(
              content: emailContent,
              subject: emailSubject,
              toRecipients: {toRecipient},
              ccRecipients: {ccRecipient},
              bccRecipients: {bccRecipient},
              replyToRecipients: {replyToRecipient},
              identity: selectedIdentity,
              attachments: [attachment],
              hasReadReceipt: false
            );

            await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
              child: const Stack(children: [ComposerView()])));
            await tester.pump();
            
            // act
            final saveAsDraftButton = find.ancestor(
              of: find.byType(InkWell),
              matching: find.byWidgetPredicate(
                (widget) => widget is TMailButtonWidget
                  && widget.icon == ImagePaths().icSaveToDraft));
            await tester.tap(saveAsDraftButton);
            await tester.pump();
            await untilCalled(
              mockCreateNewAndSaveEmailToDraftsInteractor.execute(
                createEmailRequest: anyNamed('createEmailRequest'),
                cancelToken: anyNamed('cancelToken')));
            
            // assert
            expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);

            // tear down
            PlatformInfo.isTestingForWeb = false;
          });
        });

        testWidgets(
          'should update _savedEmailDraftHash '
          'when user click save draft button '
          'and UpdateEmailDraftsSuccess is returned',
        (tester) async {
          await tester.runAsync(() async {
            // arrange
            PlatformInfo.isTestingForWeb = true;
            InAppWebViewPlatform.instance = MockWebViewPlatform();

            when(mockUploadController.uploadInlineViewState).thenReturn(
              Rx(Right(UIState.idle)));
            when(mockUploadController.listUploadAttachments).thenReturn(
              RxList<UploadFileState>());
            
            Get.put(composerController!);
            composerController?.richTextWebController = mockRichTextWebController;

            composerController?.onChangeTextEditorWeb(emailContent);
            composerController?.subjectEmail.value = emailSubject;
            composerController?.listToEmailAddress = [toRecipient];
            composerController?.listCcEmailAddress = [ccRecipient];
            composerController?.listBccEmailAddress = [bccRecipient];
            composerController?.listReplyToEmailAddress = [replyToRecipient];
            final selectedIdentity = Identity(id: IdentityId(Id('alice')));
            composerController?.identitySelected.value = selectedIdentity;
            when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);

            composerController?.composerArguments.value = ComposerArguments(
              emailActionType: EmailActionType.editDraft);
            when(
              mockCreateNewAndSaveEmailToDraftsInteractor.execute(
                createEmailRequest: anyNamed('createEmailRequest'),
                cancelToken: anyNamed('cancelToken')))
              .thenAnswer((_) => Stream.value(
                Right(UpdateEmailDraftsSuccess(EmailId(Id('123'))))));

            final savedEmailDraft = SavedEmailDraft(
              content: emailContent,
              subject: emailSubject,
              toRecipients: {toRecipient},
              ccRecipients: {ccRecipient},
              bccRecipients: {bccRecipient},
              replyToRecipients: {replyToRecipient},
              identity: selectedIdentity,
              attachments: [attachment],
              hasReadReceipt: false
            );

            await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
              child: const Stack(children: [ComposerView()])));
            await tester.pump();
            
            // act
            final saveAsDraftButton = find.ancestor(
              of: find.byType(InkWell),
              matching: find.byWidgetPredicate(
                (widget) => widget is TMailButtonWidget
                  && widget.icon == ImagePaths().icSaveToDraft));
            await tester.tap(saveAsDraftButton);
            await tester.pump();
            await untilCalled(
              mockCreateNewAndSaveEmailToDraftsInteractor.execute(
                createEmailRequest: anyNamed('createEmailRequest'),
                cancelToken: anyNamed('cancelToken')));
            
            // assert
            expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);

            // tear down
            PlatformInfo.isTestingForWeb = false;
          });
        });

        test(
          'should update _savedEmailDraftHash with the same value'
          'and call _updateSavedEmailDraftHash twice '
          'when there is a new view state '
          'and the state is GetEmailContentSuccess',
        () async {
          // arrange
          composerController?.richTextMobileTabletController = mockRichTextMobileTabletController;
          when(mockRichTextMobileTabletController.htmlEditorApi).thenReturn(
            mockHtmlEditorApi);
          
          when(mockHtmlEditorApi.getText()).thenAnswer((_) async => emailContent);
          composerController?.subjectEmail.value = emailSubject;
          composerController?.listToEmailAddress = [toRecipient];
          composerController?.listCcEmailAddress = [ccRecipient];
          composerController?.listBccEmailAddress = [bccRecipient];
          composerController?.listReplyToEmailAddress = [replyToRecipient];
          composerController?.hasRequestReadReceipt.value = alwaysReadReceiptEnabled;

          const idenityId = 'some-identity-id';
          final identity = Identity(id: IdentityId(Id(idenityId)));
          composerController?.identitySelected.value = identity;
          composerController?.listFromIdentities.add(identity);
          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);

          final state = GetEmailContentSuccess(
            htmlEmailContent: '',
            emailCurrent: Email(
              identityHeader: {IndividualHeaderIdentifier.identityHeader: idenityId},
              headers: {EmailHeader(EmailProperty.headerMdnKey, 'value')}));

          final savedEmailDraft = SavedEmailDraft(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: identity,
            attachments: [attachment],
            hasReadReceipt: alwaysReadReceiptEnabled
          );
          
          // act
          composerController?.handleSuccessViewState(state);
          await untilCalled(mockHtmlEditorApi.getText());
          
          // assert
          verify(mockHtmlEditorApi.getText()).called(2);
          expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);
        });

        test(
          'should update _savedEmailDraftHash '
          'when restoring signature button finished',
        () async {
          // arrange
          PlatformInfo.isTestingForWeb = true;

          const emailContentWithSignature = '<div class="tmail-signature"></div>';
          const emailContentWithSignatureButton = '<div class="tmail-signature"><button class="tmail-signature-button"></button></div>';
          
          when(mockHtmlEditorApi.getText()).thenAnswer((_) async => emailContentWithSignatureButton);
          composerController?.subjectEmail.value = emailSubject;
          composerController?.listToEmailAddress = [toRecipient];
          composerController?.listCcEmailAddress = [ccRecipient];
          composerController?.listBccEmailAddress = [bccRecipient];
          composerController?.listReplyToEmailAddress = [replyToRecipient];
          composerController?.identitySelected.value = identity;
          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);
          composerController?.hasRequestReadReceipt.value = alwaysReadReceiptEnabled;

          final savedEmailDraft = SavedEmailDraft(
            content: emailContentWithSignatureButton,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: identity,
            attachments: [attachment],
            hasReadReceipt: alwaysReadReceiptEnabled
          );
          
          // act
          await composerController?.restoreCollapsibleButton(emailContentWithSignature);
          expect(composerController?.restoringSignatureButton, true);
          composerController?.onChangeTextEditorWeb(emailContentWithSignatureButton);
          await Future.delayed(Duration.zero);
          
          // assert
          expect(composerController?.restoringSignatureButton, false);
          expect(composerController?.savedEmailDraftHash, savedEmailDraft.hashCode);

          // tear down
          PlatformInfo.isTestingForWeb = false;
        });
      });

      group('email action type is neither EmailActionType.compose nor EmailActionType.editDraft:', () {
        setUp(() {
          composerController?.composerArguments.value = ComposerArguments(
          emailActionType: EmailActionType.reply);
        });

        test(
          'should not update _savedEmailDraftHash '
          'when there is a new view state '
          'and the state is GetAlwaysReadReceiptSettingSuccess',
        () async {
          // arrange
          composerController?.richTextMobileTabletController = mockRichTextMobileTabletController;
          when(mockRichTextMobileTabletController.htmlEditorApi).thenReturn(
            mockHtmlEditorApi);

          final state = GetAlwaysReadReceiptSettingSuccess(
            alwaysReadReceiptEnabled: true);
          
          // act
          composerController?.handleSuccessViewState(state);
          
          // assert
          expect(composerController?.savedEmailDraftHash, isNull);
        });

        test(
          'should not update _savedEmailDraftHash '
          'when there is a new view state '
          'and the state is GetAlwaysReadReceiptSettingFailure',
        () async {
          // arrange
          composerController?.richTextMobileTabletController = mockRichTextMobileTabletController;
          when(mockRichTextMobileTabletController.htmlEditorApi).thenReturn(
            mockHtmlEditorApi);

          final state = GetAlwaysReadReceiptSettingFailure(Exception());
          
          // act
          composerController?.handleFailureViewState(state);
          
          // assert
          expect(composerController?.savedEmailDraftHash, isNull);
        });

        test(
          'should not update _savedEmailDraftHash '
          'when _initIdentities is called '
          'and listFromIdentities is not empty '
          'and selectedIdentity is available',
        () async {
          // arrange
          PlatformInfo.isTestingForWeb = true;

          final selectedIdentity = Identity(id: IdentityId(Id('alice')));

          composerController = ComposerController(
            mockLocalFilePickerInteractor,
            mockLocalImagePickerInteractor,
            mockGetEmailContentInteractor,
            mockGetAllIdentitiesInteractor,
            mockUploadController,
            mockRemoveComposerCacheOnWebInteractor,
            mockSaveComposerCacheOnWebInteractor,
            mockDownloadImageAsBase64Interactor,
            mockTransformHtmlEmailContentInteractor,
            mockGetAlwaysReadReceiptSettingInteractor,
            mockCreateNewAndSendEmailInteractor,
            mockCreateNewAndSaveEmailToDraftsInteractor,
            mockPrintEmailInteractor,
            composerArgs: ComposerArguments(
              emailActionType: EmailActionType.reply,
              emailContents: emailContent,
              presentationEmail: PresentationEmail(
                mailboxContain: PresentationMailbox(
                  MailboxId(Id('some-mailbox-id')),
                  role: PresentationMailbox.roleJunk,
                ),
              ),
              selectedIdentityId: selectedIdentity.id,
              identities: [selectedIdentity],
            ),
          );

          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);
          
          // act
          composerController?.onReady();
          await Future.delayed(Duration.zero);
          
          // assert
          expect(composerController?.savedEmailDraftHash, isNull);

          // tear down
          PlatformInfo.isTestingForWeb = false;
        });

        test(
          'should not update _savedEmailDraftHash '
          'when _initIdentities is called '
          'and listFromIdentities is not empty '
          'and selectedIdentity is not available',
        () async {
          // arrange
          PlatformInfo.isTestingForWeb = true;

          final identity = Identity(id: IdentityId(Id('alice')));

          composerController = ComposerController(
            mockLocalFilePickerInteractor,
            mockLocalImagePickerInteractor,
            mockGetEmailContentInteractor,
            mockGetAllIdentitiesInteractor,
            mockUploadController,
            mockRemoveComposerCacheOnWebInteractor,
            mockSaveComposerCacheOnWebInteractor,
            mockDownloadImageAsBase64Interactor,
            mockTransformHtmlEmailContentInteractor,
            mockGetAlwaysReadReceiptSettingInteractor,
            mockCreateNewAndSendEmailInteractor,
            mockCreateNewAndSaveEmailToDraftsInteractor,
            mockPrintEmailInteractor,
            composerArgs: ComposerArguments(
              emailActionType: EmailActionType.reply,
              emailContents: emailContent,
              presentationEmail: PresentationEmail(
                mailboxContain: PresentationMailbox(
                  MailboxId(Id('some-mailbox-id')),
                  role: PresentationMailbox.roleJunk,
                ),
              ),
              identities: [identity],
            ),
          );

          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);
          
          // act
          composerController?.onReady();
          await Future.delayed(Duration.zero);
          
          // assert
          expect(composerController?.savedEmailDraftHash, isNull);

          // tear down
          PlatformInfo.isTestingForWeb = false;
        });

        test(
          'should not update _savedEmailDraftHash '
          'when _initIdentities is called '
          'and listFromIdentities is empty '
          'and selectedIdentity is available',
        () async {
          // arrange
          PlatformInfo.isTestingForWeb = true;

          final selectedIdentity = Identity(
            id: IdentityId(Id('alice')),
            mayDelete: true);

          composerController = ComposerController(
            mockLocalFilePickerInteractor,
            mockLocalImagePickerInteractor,
            mockGetEmailContentInteractor,
            mockGetAllIdentitiesInteractor,
            mockUploadController,
            mockRemoveComposerCacheOnWebInteractor,
            mockSaveComposerCacheOnWebInteractor,
            mockDownloadImageAsBase64Interactor,
            mockTransformHtmlEmailContentInteractor,
            mockGetAlwaysReadReceiptSettingInteractor,
            mockCreateNewAndSendEmailInteractor,
            mockCreateNewAndSaveEmailToDraftsInteractor,
            mockPrintEmailInteractor,
            composerArgs: ComposerArguments(
              emailActionType: EmailActionType.reply,
              emailContents: emailContent,
              presentationEmail: PresentationEmail(
                mailboxContain: PresentationMailbox(
                  MailboxId(Id('some-mailbox-id')),
                  role: PresentationMailbox.roleJunk,
                ),
              ),
              selectedIdentityId: selectedIdentity.id,
            ),
          );

          when(mockGetAllIdentitiesInteractor.execute(any, any)).thenAnswer(
            (_) => Stream.value(
              Right(GetAllIdentitiesSuccess([selectedIdentity], null))));

          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);
          
          // act
          composerController?.onReady();
          await Future.delayed(Duration.zero);
          
          // assert
          expect(composerController?.savedEmailDraftHash, isNull);

          // tear down
          PlatformInfo.isTestingForWeb = false;
        });

        test(
          'should not update _savedEmailDraftHash '
          'when _initIdentities is called '
          'and listFromIdentities is empty '
          'and selectedIdentity is not available',
        () async {
          // arrange
          PlatformInfo.isTestingForWeb = true;

          final identity = Identity(
            id: IdentityId(Id('alice')),
            mayDelete: true);

          composerController = ComposerController(
            mockLocalFilePickerInteractor,
            mockLocalImagePickerInteractor,
            mockGetEmailContentInteractor,
            mockGetAllIdentitiesInteractor,
            mockUploadController,
            mockRemoveComposerCacheOnWebInteractor,
            mockSaveComposerCacheOnWebInteractor,
            mockDownloadImageAsBase64Interactor,
            mockTransformHtmlEmailContentInteractor,
            mockGetAlwaysReadReceiptSettingInteractor,
            mockCreateNewAndSendEmailInteractor,
            mockCreateNewAndSaveEmailToDraftsInteractor,
            mockPrintEmailInteractor,
            composerArgs: ComposerArguments(
              emailActionType: EmailActionType.reply,
              emailContents: emailContent,
              presentationEmail: PresentationEmail(
                mailboxContain: PresentationMailbox(
                  MailboxId(Id('some-mailbox-id')),
                  role: PresentationMailbox.roleJunk,
                ),
              ),
            ),
          );

          when(mockGetAllIdentitiesInteractor.execute(any, any)).thenAnswer(
            (_) => Stream.value(
              Right(GetAllIdentitiesSuccess([identity], null))));

          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);
          
          // act
          composerController?.onReady();
          await Future.delayed(Duration.zero);
          
          // assert
          expect(composerController?.savedEmailDraftHash, isNull);

          // tear down
          PlatformInfo.isTestingForWeb = false;
        });

        test(
          'should not update _savedEmailDraftHash '
          'when there is a new view state '
          'and the state is GetEmailContentSuccess',
        () async {
          // arrange
          composerController?.richTextMobileTabletController = mockRichTextMobileTabletController;
          when(mockRichTextMobileTabletController.htmlEditorApi).thenReturn(
            mockHtmlEditorApi);

          const idenityId = 'some-identity-id';
          final identity = Identity(id: IdentityId(Id(idenityId)));
          composerController?.identitySelected.value = identity;
          composerController?.listFromIdentities.add(identity);

          final state = GetEmailContentSuccess(
            htmlEmailContent: emailContent,
            emailCurrent: Email(
              identityHeader: {IndividualHeaderIdentifier.identityHeader: idenityId}));
          
          // act
          composerController?.handleSuccessViewState(state);
          
          // assert
          verifyNever(mockHtmlEditorApi.getText());
          expect(composerController?.savedEmailDraftHash, isNull);
        });
      });
    });
  });
}