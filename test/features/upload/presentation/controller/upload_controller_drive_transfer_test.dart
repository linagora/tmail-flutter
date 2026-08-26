import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:mockito/annotations.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_attachment_interactor.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/drive_transfer_placeholder.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_status.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import 'upload_controller_drive_transfer_test.mocks.dart';

@GenerateNiceMocks([
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
  const taskId = UploadTaskId('drive-task-1');

  setUp(() {
    Get.testMode = true;
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

    controller = UploadController(UploadAttachmentInteractor(MockComposerRepository()));
  });

  tearDown(() => Get.reset());

  DriveTransferPlaceholder placeholder({UploadTaskId id = taskId}) => DriveTransferPlaceholder(
        taskId: id,
        fileName: 'file.pdf',
        fileSize: 100,
        mimeType: 'application/pdf',
      );

  group('UploadController::addDownloadingPlaceholders::', () {
    test('Should add a waiting chip per placeholder', () {
      controller.addDownloadingPlaceholders([placeholder()]);

      expect(controller.listUploadAttachments, hasLength(1));
      expect(controller.listUploadAttachments.single.uploadStatus, UploadFileStatus.waiting);
      expect(controller.listUploadAttachments.single.uploadTaskId, taskId);
    });

    test('Should no-op on an empty list', () {
      controller.addDownloadingPlaceholders([]);

      expect(controller.listUploadAttachments, isEmpty);
    });
  });

  group('UploadController::resolveDriveTransferSuccess::', () {
    test('Should flip the matching chip to succeed with its attachment', () {
      controller.addDownloadingPlaceholders([placeholder()]);
      final attachment = Attachment(blobId: Id('blob-1'), size: UnsignedInt(100));

      controller.resolveDriveTransferSuccess(taskId, attachment);

      final state = controller.listUploadAttachments.single;
      expect(state.uploadStatus, UploadFileStatus.succeed);
      expect(state.attachment, attachment);
    });
  });

  group('UploadController::resolveDriveTransferSuccess after deletion::', () {
    test('Should not restore a chip whose attachment was already deleted', () {
      controller.addDownloadingPlaceholders([placeholder()]);
      controller.deleteFileUploaded(taskId);

      // Transfer completed after the user removed the waiting chip.
      controller.resolveDriveTransferSuccess(
        taskId,
        Attachment(blobId: Id('blob-1'), size: UnsignedInt(100)),
      );

      expect(controller.listUploadAttachments, isEmpty);
      expect(controller.attachmentsUploaded, isEmpty);
    });
  });

  group('UploadController::resolveDriveTransferFailure::', () {
    test('Should remove the matching chip, matching the plain-upload failure path', () {
      controller.addDownloadingPlaceholders([placeholder()]);

      controller.resolveDriveTransferFailure(taskId);

      expect(controller.listUploadAttachments, isEmpty);
    });
  });

  group('UploadController::addDownloadingPlaceholders + resolve ordering::', () {
    test('Should place all placeholders before any resolution', () {
      const secondTaskId = UploadTaskId('drive-task-2');
      controller.addDownloadingPlaceholders([
        placeholder(),
        placeholder(id: secondTaskId),
      ]);

      expect(controller.listUploadAttachments, hasLength(2));
      expect(
        controller.listUploadAttachments.map((s) => s.uploadStatus),
        everyElement(UploadFileStatus.waiting),
      );

      controller.resolveDriveTransferSuccess(
        taskId,
        Attachment(blobId: Id('blob-1'), size: UnsignedInt(100)),
      );

      expect(controller.listUploadAttachments, hasLength(2));
    });
  });

  group('UploadController::onClose::', () {
    test('Should cancel every pending drive-transfer token before clearing', () {
      final cancelToken = CancelToken();
      controller.addDownloadingPlaceholders([
        DriveTransferPlaceholder(
          taskId: taskId,
          fileName: 'file.pdf',
          fileSize: 100,
          mimeType: 'application/pdf',
          cancelToken: cancelToken,
        ),
      ]);

      controller.onClose();

      expect(cancelToken.isCancelled, isTrue);
      expect(controller.listUploadAttachments, isEmpty);
    });
  });

  group('UploadController::refreshAllAttachments::', () {
    test('Should keep a waiting drive chip that the server response cannot rebuild', () {
      final cancelToken = CancelToken();
      controller.addDownloadingPlaceholders([
        DriveTransferPlaceholder(
          taskId: taskId,
          fileName: 'file.pdf',
          fileSize: 100,
          mimeType: 'application/pdf',
          cancelToken: cancelToken,
        ),
      ]);
      final savedAttachment = Attachment(blobId: Id('blob-1'), size: UnsignedInt(100));

      // Draft saved while the transfer is still running.
      controller.refreshAllAttachments([savedAttachment], []);

      expect(controller.listUploadAttachments, hasLength(2));
      final waitingState = controller.getUploadFileId(taskId);
      expect(waitingState?.uploadStatus, UploadFileStatus.waiting);
      expect(waitingState?.cancelToken, same(cancelToken));
      expect(cancelToken.isCancelled, isFalse);
    });

    test('Should still resolve a chip that survived the refresh', () {
      controller.addDownloadingPlaceholders([placeholder()]);
      controller.refreshAllAttachments([], []);

      final attachment = Attachment(blobId: Id('blob-2'), size: UnsignedInt(100));
      controller.resolveDriveTransferSuccess(taskId, attachment);

      expect(controller.getUploadFileId(taskId)?.uploadStatus, UploadFileStatus.succeed);
      expect(controller.attachmentsUploaded, contains(attachment));
    });

    test('Should not duplicate an already completed attachment', () {
      final attachment = Attachment(blobId: Id('blob-3'), size: UnsignedInt(100));
      controller.initializeUploadAttachments([attachment]);

      controller.refreshAllAttachments([attachment], []);

      expect(controller.listUploadAttachments, hasLength(1));
    });
  });
}
