import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/logging/app_logger_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_attachment_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/concurrency_gate.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/drive_attachment_transfer_runner.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_repository.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/upload_drive_document_from_url_interactor.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/drive_transfer_placeholder.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:workplace/domain/entity/drive_document.dart';

import '../../../../fixtures/capturing_log_handler.dart';
import 'drive_upload_failure_single_event_test.mocks.dart';

/// Wires the real interactor -> runner -> controller chain so the "one durable
/// event per failed upload" invariant is proven across the whole path, not
/// asserted unit by unit.
@GenerateNiceMocks([
  MockSpec<UploadFromUrlRepository>(),
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
  MockSpec<ToastManager>(),
  MockSpec<TwakeAppManager>(),
  MockSpec<ComposerRepository>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UploadController controller;
  late MockUploadFromUrlRepository repository;
  late CapturingLogHandler logHandler;

  final accountId = AccountId(Id('account-1'));
  final uploadUri = Uri.parse('https://mail.example.com/upload-from-url/account-1');

  setUp(() {
    Get.put<CachingManager>(MockCachingManager());
    Get.put<LanguageCacheManager>(MockLanguageCacheManager());
    Get.put<AuthorizationInterceptors>(MockAuthorizationInterceptors());
    Get.put<AuthorizationInterceptors>(
      MockAuthorizationInterceptors(),
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

    repository = MockUploadFromUrlRepository();
    controller = UploadController(UploadAttachmentInteractor(MockComposerRepository()));
    logHandler = CapturingLogHandler();
    AppLoggerRegistry.instance.registerHandler(logHandler);
  });

  tearDown(() {
    AppLoggerRegistry.instance.resetForTesting();
    Get.reset();
  });

  testWidgets(
    'WHEN one backend failure travels interactor -> runner -> resolveDriveTransferFailure\n'
    'THEN exactly ONE durable error event is emitted\n'
    'AND it carries no file name, account id or URL',
    (tester) async {
      const sensitiveName = 'SENSITIVE-PAYSLIP-2026.pdf';
      const sensitiveLink = 'https://drive.example.com/SENSITIVE-TOKEN-8c1f/file.pdf';

      // A real context, as production always has: the toast branch runs
      // instead of the no-context fallback, which would add a second event.
      await tester.pumpWidget(GetMaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocalizationService.supportedLocales,
        home: Scaffold(body: Container()),
      ));
      await tester.pumpAndSettle();

      when(repository.uploadFromUrl(any))
          .thenThrow(Exception('backend rejected the upload'));

      final interactor = UploadDriveDocumentFromUrlInteractor(repository);
      final runner = DriveAttachmentTransferRunner(
        uploadFromUrl: interactor.execute,
        gate: ConcurrencyGate(3),
      );

      final outcome = await runner.transfer((
        docs: [
          DriveDocument(
            id: 'doc-1',
            name: sensitiveName,
            size: 100,
            mimeType: 'application/pdf',
            downloadLink: Uri.parse(sensitiveLink),
          ),
        ],
        accountId: accountId,
        uploadUri: uploadUri,
        onPlaceholdersReady: (placeholders) => controller.addDownloadingPlaceholders(
          placeholders.cast<DriveTransferPlaceholder>(),
        ),
        onSuccess: controller.resolveDriveTransferSuccess,
        onFailure: controller.resolveDriveTransferFailure,
      ));
      await tester.pumpAndSettle();

      expect(outcome, (started: true, succeeded: 0, failed: 1));
      expect(controller.listUploadAttachments, isEmpty);

      expect(
        logHandler.errorRecords,
        hasLength(1),
        reason: 'one failed upload must not raise duplicate Sentry issues',
      );
      final record = logHandler.errorRecords.single;
      expect(record.rawMessage, isNot(contains(sensitiveName)));
      expect(record.rawMessage, isNot(contains('SENSITIVE-TOKEN-8c1f')));
      expect(record.rawMessage, isNot(contains('account-1')));
    },
  );
}
