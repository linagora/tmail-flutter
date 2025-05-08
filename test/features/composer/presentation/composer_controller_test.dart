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
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:tmail_ui_user/features/base/before_reconnect_manager.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
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
import 'package:tmail_ui_user/features/composer/presentation/extensions/setup_selected_identity_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/formatting_options_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/saved_composing_email.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/save_template_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/transform_html_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_by_id_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/draggable_app_state.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_server_setting_interactor.dart';
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
  MockSpec<RemoveComposerCacheByIdOnWebInteractor>(),
  MockSpec<SaveComposerCacheOnWebInteractor>(),
  MockSpec<DownloadImageAsBase64Interactor>(),
  MockSpec<TransformHtmlEmailContentInteractor>(),
  MockSpec<GetServerSettingInteractor>(),
  MockSpec<CreateNewAndSendEmailInteractor>(),
  MockSpec<CreateNewAndSaveEmailToDraftsInteractor>(),
  MockSpec<PrintEmailInteractor>(),
  MockSpec<ComposerRepository>(),
  MockSpec<SaveTemplateEmailInteractor>(),

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
  late MockRemoveComposerCacheByIdOnWebInteractor mockRemoveComposerCacheByIdOnWebInteractor;
  late MockSaveComposerCacheOnWebInteractor mockSaveComposerCacheOnWebInteractor;
  late MockDownloadImageAsBase64Interactor mockDownloadImageAsBase64Interactor;
  late MockTransformHtmlEmailContentInteractor mockTransformHtmlEmailContentInteractor;
  late MockGetServerSettingInteractor mockGetServerSettingInteractor;
  late MockCreateNewAndSendEmailInteractor mockCreateNewAndSendEmailInteractor;
  late MockCreateNewAndSaveEmailToDraftsInteractor mockCreateNewAndSaveEmailToDraftsInteractor;
  late MockPrintEmailInteractor mockPrintEmailInteractor;
  late MockComposerRepository mockComposerRepository;
  late MockSaveTemplateEmailInteractor mockSaveTemplateEmailInteractor;

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
    mockRemoveComposerCacheByIdOnWebInteractor = MockRemoveComposerCacheByIdOnWebInteractor();
    mockSaveComposerCacheOnWebInteractor = MockSaveComposerCacheOnWebInteractor();
    mockDownloadImageAsBase64Interactor = MockDownloadImageAsBase64Interactor();
    mockTransformHtmlEmailContentInteractor = MockTransformHtmlEmailContentInteractor();
    mockGetServerSettingInteractor = MockGetServerSettingInteractor();
    mockCreateNewAndSendEmailInteractor = MockCreateNewAndSendEmailInteractor();
    mockCreateNewAndSaveEmailToDraftsInteractor = MockCreateNewAndSaveEmailToDraftsInteractor();
    mockPrintEmailInteractor = MockPrintEmailInteractor();
    mockComposerRepository = MockComposerRepository();
    mockSaveTemplateEmailInteractor = MockSaveTemplateEmailInteractor();

    composerController = ComposerController(
      mockLocalFilePickerInteractor,
      mockLocalImagePickerInteractor,
      mockGetEmailContentInteractor,
      mockGetAllIdentitiesInteractor,
      mockUploadController,
      mockRemoveComposerCacheByIdOnWebInteractor,
      mockSaveComposerCacheOnWebInteractor,
      mockDownloadImageAsBase64Interactor,
      mockTransformHtmlEmailContentInteractor,
      mockGetServerSettingInteractor,
      mockCreateNewAndSendEmailInteractor,
      mockCreateNewAndSaveEmailToDraftsInteractor,
      mockPrintEmailInteractor,
      mockComposerRepository,
      mockSaveTemplateEmailInteractor,
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
      const alwaysReadReceiptEnabled = false;
      const isMarkAsImportant = false;

      group('email action type is EmailActionType.compose:', () {
        test(
          'Should update _savedEmailDraftHash\n'
          'When screenDisplayMode is normal',
        () async {
          // arrange
          final composerArguments = ComposerArguments(
            emailActionType: EmailActionType.compose,
            displayMode: ScreenDisplayMode.normal,
            identities: [identity],
            selectedIdentityId: identity.id,
          );
          composerController?.composerArguments.value = composerArguments;
          composerController?.richTextMobileTabletController = mockRichTextMobileTabletController;
          composerController?.subjectEmail.value = emailSubject;
          composerController?.listToEmailAddress = [toRecipient];
          composerController?.listCcEmailAddress = [ccRecipient];
          composerController?.listBccEmailAddress = [bccRecipient];
          composerController?.listReplyToEmailAddress = [replyToRecipient];
          composerController?.hasRequestReadReceipt.value = alwaysReadReceiptEnabled;
          composerController?.isMarkAsImportant.value = isMarkAsImportant;
          composerController?.screenDisplayMode.value = composerArguments.displayMode;
          composerController?.currentEmailActionType = composerArguments.emailActionType;
          composerController?.listFromIdentities.value = composerArguments.identities!;

          when(mockRichTextMobileTabletController.htmlEditorApi).thenReturn(mockHtmlEditorApi);
          when(mockHtmlEditorApi.getText()).thenAnswer((_) async => emailContent);
          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);
          when(mockComposerRepository.removeCollapsedExpandedSignatureEffect(
            emailContent: anyNamed('emailContent'),
          )).thenAnswer((_) async => emailContent);

          final savedEmailDraft = SavedComposingEmail(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: identity,
            attachments: [attachment],
            hasReadReceipt: alwaysReadReceiptEnabled,
            isMarkAsImportant: isMarkAsImportant,
          );
          
          // act
          composerController?.setupSelectedIdentity();

          await untilCalled(mockHtmlEditorApi.onDocumentChanged());
          await untilCalled(mockHtmlEditorApi.getText());
          await untilCalled(
              mockComposerRepository.removeCollapsedExpandedSignatureEffect(
                  emailContent: anyNamed('emailContent')));

          // assert
          expect(
            composerController?.savedEmailDraftHash,
            equals(savedEmailDraft.asString().hashCode),
          );
        });

        test(
          'Should update _savedEmailDraftHash\n'
          'When screenDisplayMode is minimize',
        () async {
          // arrange
          final composerArguments = ComposerArguments(
            emailActionType: EmailActionType.compose,
            displayMode: ScreenDisplayMode.minimize,
            identities: [identity],
            selectedIdentityId: identity.id,
          );
          composerController?.composerArguments.value = composerArguments;
          composerController?.richTextMobileTabletController = mockRichTextMobileTabletController;
          composerController?.subjectEmail.value = emailSubject;
          composerController?.listToEmailAddress = [toRecipient];
          composerController?.listCcEmailAddress = [ccRecipient];
          composerController?.listBccEmailAddress = [bccRecipient];
          composerController?.listReplyToEmailAddress = [replyToRecipient];
          composerController?.hasRequestReadReceipt.value = alwaysReadReceiptEnabled;
          composerController?.isMarkAsImportant.value = isMarkAsImportant;
          composerController?.screenDisplayMode.value = composerArguments.displayMode;
          composerController?.currentEmailActionType = composerArguments.emailActionType;
          composerController?.listFromIdentities.value = composerArguments.identities!;

          when(mockRichTextMobileTabletController.htmlEditorApi).thenReturn(mockHtmlEditorApi);
          when(mockHtmlEditorApi.getText()).thenAnswer((_) async => emailContent);
          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);
          when(mockComposerRepository.removeCollapsedExpandedSignatureEffect(
            emailContent: anyNamed('emailContent'),
          )).thenAnswer((_) async => emailContent);

          final savedEmailDraft = SavedComposingEmail(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: identity,
            attachments: [attachment],
            hasReadReceipt: alwaysReadReceiptEnabled,
            isMarkAsImportant: isMarkAsImportant,
          );

          // act
          composerController?.setupSelectedIdentityWithoutApplySignature();

          await untilCalled(mockHtmlEditorApi.getText());
          await untilCalled(
              mockComposerRepository.removeCollapsedExpandedSignatureEffect(
                  emailContent: anyNamed('emailContent')));

          // assert
          expect(
            composerController?.savedEmailDraftHash,
            equals(savedEmailDraft.asString().hashCode),
          );
        });

        testWidgets(
          'Should update _savedEmailDraftHash\n'
          'When user click save draft button\n'
          'And SaveEmailAsDraftsSuccess is returned',
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

            composerController?.setTextEditorWeb(emailContent);
            composerController?.subjectEmail.value = emailSubject;
            composerController?.listToEmailAddress = [toRecipient];
            composerController?.listCcEmailAddress = [ccRecipient];
            composerController?.listBccEmailAddress = [bccRecipient];
            composerController?.listReplyToEmailAddress = [replyToRecipient];
            when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);
            when(mockComposerRepository.removeCollapsedExpandedSignatureEffect(
              emailContent: anyNamed('emailContent'),
            )).thenAnswer((_) async => emailContent);

            final selectedIdentity = Identity(id: IdentityId(Id('alice')));
            composerController?.identitySelected.value = selectedIdentity;
            composerController?.composerArguments.value = ComposerArguments();
            when(
              mockCreateNewAndSaveEmailToDraftsInteractor.execute(
                createEmailRequest: anyNamed('createEmailRequest'),
                cancelToken: anyNamed('cancelToken')))
              .thenAnswer((_) => Stream.value(
                Right(SaveEmailAsDraftsSuccess(EmailId(Id('123')), null))));

            final savedEmailDraft = SavedComposingEmail(
              content: emailContent,
              subject: emailSubject,
              toRecipients: {toRecipient},
              ccRecipients: {ccRecipient},
              bccRecipients: {bccRecipient},
              replyToRecipients: {replyToRecipient},
              identity: selectedIdentity,
              attachments: [attachment],
              hasReadReceipt: false,
              isMarkAsImportant: false,
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
            expect(
              composerController?.savedEmailDraftHash,
              equals(savedEmailDraft.asString().hashCode),
            );

            // tear down
            PlatformInfo.isTestingForWeb = false;
          });
        });

        testWidgets(
          'Should update _savedEmailDraftHash\n'
          'When user click save draft button\n'
          'And UpdateEmailDraftsSuccess is returned',
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
            when(mockComposerRepository.removeCollapsedExpandedSignatureEffect(
              emailContent: anyNamed('emailContent'),
            )).thenAnswer((_) async => emailContent);

            final selectedIdentity = Identity(id: IdentityId(Id('alice')));
            composerController?.identitySelected.value = selectedIdentity;
            composerController?.composerArguments.value = ComposerArguments();
            when(
              mockCreateNewAndSaveEmailToDraftsInteractor.execute(
                createEmailRequest: anyNamed('createEmailRequest'),
                cancelToken: anyNamed('cancelToken')))
              .thenAnswer((_) => Stream.value(
                Right(UpdateEmailDraftsSuccess(EmailId(Id('123'))))));

            final savedEmailDraft = SavedComposingEmail(
              content: emailContent,
              subject: emailSubject,
              toRecipients: {toRecipient},
              ccRecipients: {ccRecipient},
              bccRecipients: {bccRecipient},
              replyToRecipients: {replyToRecipient},
              identity: selectedIdentity,
              attachments: [attachment],
              hasReadReceipt: false,
              isMarkAsImportant: false,
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
            expect(
              composerController?.savedEmailDraftHash,
              equals(savedEmailDraft.asString().hashCode),
            );

            // tear down
            PlatformInfo.isTestingForWeb = false;
          });
        });
      });

      group('email action type is EmailActionType.editDraft:', () {
        test(
          'Should update _savedEmailDraftHash\n'
          'When screenDisplayMode is normal',
        () async {
          // arrange
          final composerArguments = ComposerArguments(
            emailActionType: EmailActionType.editDraft,
            displayMode: ScreenDisplayMode.normal,
            identities: [identity],
            selectedIdentityId: identity.id,
          );
          composerController?.composerArguments.value = composerArguments;
          composerController?.richTextMobileTabletController = mockRichTextMobileTabletController;
          composerController?.subjectEmail.value = emailSubject;
          composerController?.listToEmailAddress = [toRecipient];
          composerController?.listCcEmailAddress = [ccRecipient];
          composerController?.listBccEmailAddress = [bccRecipient];
          composerController?.listReplyToEmailAddress = [replyToRecipient];
          composerController?.hasRequestReadReceipt.value = alwaysReadReceiptEnabled;
          composerController?.isMarkAsImportant.value = isMarkAsImportant;
          composerController?.screenDisplayMode.value = composerArguments.displayMode;
          composerController?.currentEmailActionType = composerArguments.emailActionType;
          composerController?.listFromIdentities.value = composerArguments.identities!;
          composerController?.identitySelected.value = null;

          when(mockRichTextMobileTabletController.htmlEditorApi).thenReturn(mockHtmlEditorApi);
          when(mockHtmlEditorApi.getText()).thenAnswer((_) async => emailContent);
          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);
          when(mockComposerRepository.removeCollapsedExpandedSignatureEffect(
            emailContent: anyNamed('emailContent'),
          )).thenAnswer((_) async => emailContent);

          final savedEmailDraft = SavedComposingEmail(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: identity,
            attachments: [attachment],
            hasReadReceipt: alwaysReadReceiptEnabled,
            isMarkAsImportant: isMarkAsImportant,
          );

          // act
          composerController?.setupSelectedIdentity();

          await untilCalled(mockHtmlEditorApi.getText());
          await untilCalled(
              mockComposerRepository.removeCollapsedExpandedSignatureEffect(
                  emailContent: anyNamed('emailContent')));

          // assert
          expect(
            composerController?.savedEmailDraftHash,
            equals(savedEmailDraft.asString().hashCode),
          );
        });

        test(
          'Should update _savedEmailDraftHash\n'
          'When screenDisplayMode is minimize',
        () async {
          // arrange
          final composerArguments = ComposerArguments(
            emailActionType: EmailActionType.editDraft,
            displayMode: ScreenDisplayMode.minimize,
            identities: [identity],
            selectedIdentityId: identity.id,
          );
          composerController?.composerArguments.value = composerArguments;
          composerController?.richTextMobileTabletController = mockRichTextMobileTabletController;
          composerController?.subjectEmail.value = emailSubject;
          composerController?.listToEmailAddress = [toRecipient];
          composerController?.listCcEmailAddress = [ccRecipient];
          composerController?.listBccEmailAddress = [bccRecipient];
          composerController?.listReplyToEmailAddress = [replyToRecipient];
          composerController?.hasRequestReadReceipt.value = alwaysReadReceiptEnabled;
          composerController?.isMarkAsImportant.value = isMarkAsImportant;
          composerController?.screenDisplayMode.value = composerArguments.displayMode;
          composerController?.currentEmailActionType = composerArguments.emailActionType;
          composerController?.listFromIdentities.value = composerArguments.identities!;
          composerController?.identitySelected.value = null;

          when(mockRichTextMobileTabletController.htmlEditorApi).thenReturn(mockHtmlEditorApi);
          when(mockHtmlEditorApi.getText()).thenAnswer((_) async => emailContent);
          when(mockUploadController.attachmentsUploaded).thenReturn([attachment]);
          when(mockComposerRepository.removeCollapsedExpandedSignatureEffect(
            emailContent: anyNamed('emailContent'),
          )).thenAnswer((_) async => emailContent);

          final savedEmailDraft = SavedComposingEmail(
            content: emailContent,
            subject: emailSubject,
            toRecipients: {toRecipient},
            ccRecipients: {ccRecipient},
            bccRecipients: {bccRecipient},
            replyToRecipients: {replyToRecipient},
            identity: identity,
            attachments: [attachment],
            hasReadReceipt: alwaysReadReceiptEnabled,
            isMarkAsImportant: isMarkAsImportant,
          );

          // act
          composerController?.setupSelectedIdentityWithoutApplySignature();

          await untilCalled(mockHtmlEditorApi.getText());
          await untilCalled(
              mockComposerRepository.removeCollapsedExpandedSignatureEffect(
                  emailContent: anyNamed('emailContent')));

          // assert
          expect(
            composerController?.savedEmailDraftHash,
            equals(savedEmailDraft.asString().hashCode),
          );
        });
      });
    });
  });
}