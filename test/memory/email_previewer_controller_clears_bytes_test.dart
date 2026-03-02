import 'dart:typed_data';

import 'package:core/data/network/download/download_manager.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/download/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email_previewer/email_previewer_controller.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/get_preview_email_eml_content_shared_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/get_preview_eml_content_in_memory_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/move_preview_eml_content_from_persistent_to_memory_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/preview_email_from_eml_file_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/remove_preview_email_eml_content_shared_interactor.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_user_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

class _MockDownloadManager extends Mock implements DownloadManager {
  @override
  void createAnchorElementDownloadFileWeb(Uint8List? bytes, String? filename) {
    return super.noSuchMethod(
      Invocation.method(
        #createAnchorElementDownloadFileWeb,
        [bytes, filename],
      ),
      returnValueForMissingStub: null,
    );
  }
}

class _MockGetPreviewEmailEMLContentSharedInteractor extends Mock
    implements GetPreviewEmailEMLContentSharedInteractor {}

class _MockMovePreviewEmlContentFromPersistentToMemoryInteractor extends Mock
    implements MovePreviewEmlContentFromPersistentToMemoryInteractor {}

class _MockRemovePreviewEmailEmlContentSharedInteractor extends Mock
    implements RemovePreviewEmailEmlContentSharedInteractor {}

class _MockGetPreviewEmlContentInMemoryInteractor extends Mock
    implements GetPreviewEmlContentInMemoryInteractor {}

class _MockParseEmailByBlobIdInteractor extends Mock
    implements ParseEmailByBlobIdInteractor {}

class _MockPreviewEmailFromEmlFileInteractor extends Mock
    implements PreviewEmailFromEmlFileInteractor {}

class _MockDownloadAttachmentForWebInteractor extends Mock
    implements DownloadAttachmentForWebInteractor {}

class _MockGetSessionInteractor extends Mock implements GetSessionInteractor {}
class _MockGetAuthenticatedAccountInteractor extends Mock
    implements GetAuthenticatedAccountInteractor {}
class _MockUpdateAccountCacheInteractor extends Mock
    implements UpdateAccountCacheInteractor {}
class _MockGetOidcUserInfoInteractor extends Mock
    implements GetOidcUserInfoInteractor {}

class _MockCachingManager extends Mock implements CachingManager {}
class _MockLanguageCacheManager extends Mock implements LanguageCacheManager {}
class _MockAuthorizationInterceptors extends Mock implements AuthorizationInterceptors {}
class _MockDynamicUrlInterceptors extends Mock implements DynamicUrlInterceptors {}
class _MockDeleteCredentialInteractor extends Mock implements DeleteCredentialInteractor {}
class _MockLogoutOidcInteractor extends Mock implements LogoutOidcInteractor {}
class _MockDeleteAuthorityOidcInteractor extends Mock implements DeleteAuthorityOidcInteractor {}
class _MockAppToast extends Mock implements AppToast {}
class _MockImagePaths extends Mock implements ImagePaths {}
class _MockResponsiveUtils extends Mock implements ResponsiveUtils {}
class _MockUuid extends Mock implements Uuid {}
class _MockToastManager extends Mock implements ToastManager {}
class _MockTwakeAppManager extends Mock implements TwakeAppManager {}

void main() {
  test('EmailPreviewerController clears downloadAttachmentState after success',
      () {
    Get.testMode = true;
    Get.reset();

    // BaseController / ReloadableController mandatory bindings.
    Get.put<CachingManager>(_MockCachingManager());
    Get.put<LanguageCacheManager>(_MockLanguageCacheManager());
    final auth = _MockAuthorizationInterceptors();
    Get.put<AuthorizationInterceptors>(auth);
    Get.put<AuthorizationInterceptors>(auth, tag: BindingTag.isolateTag);
    Get.put<DynamicUrlInterceptors>(_MockDynamicUrlInterceptors());
    Get.put<DeleteCredentialInteractor>(_MockDeleteCredentialInteractor());
    Get.put<LogoutOidcInteractor>(_MockLogoutOidcInteractor());
    Get.put<DeleteAuthorityOidcInteractor>(_MockDeleteAuthorityOidcInteractor());
    Get.put<AppToast>(_MockAppToast());
    Get.put<ImagePaths>(_MockImagePaths());
    Get.put<ResponsiveUtils>(_MockResponsiveUtils());
    Get.put<Uuid>(_MockUuid());
    Get.put<ToastManager>(_MockToastManager());
    Get.put<TwakeAppManager>(_MockTwakeAppManager());

    Get.put<GetSessionInteractor>(_MockGetSessionInteractor());
    Get.put<GetAuthenticatedAccountInteractor>(_MockGetAuthenticatedAccountInteractor());
    Get.put<UpdateAccountCacheInteractor>(_MockUpdateAccountCacheInteractor());
    Get.put<GetOidcUserInfoInteractor>(_MockGetOidcUserInfoInteractor());

    final downloadManager = _MockDownloadManager();
    final controller = EmailPreviewerController(
      _MockGetPreviewEmailEMLContentSharedInteractor(),
      _MockMovePreviewEmlContentFromPersistentToMemoryInteractor(),
      _MockRemovePreviewEmailEmlContentSharedInteractor(),
      _MockGetPreviewEmlContentInMemoryInteractor(),
      _MockParseEmailByBlobIdInteractor(),
      _MockPreviewEmailFromEmlFileInteractor(),
      _MockDownloadAttachmentForWebInteractor(),
      downloadManager,
    );

    final attachment = Attachment(blobId: Id('blob-1'), name: 'a.bin');
    final bytes = Uint8List.fromList([1, 2, 3]);
    final success = DownloadAttachmentForWebSuccess(
      DownloadTaskId('t1'),
      attachment,
      bytes,
      false,
      null,
    );

    // Widen parameter types to nullable so mockito matchers compile under null-safety.
    when(downloadManager.createAnchorElementDownloadFileWeb(any, any)).thenReturn(null);

    // Simulate real state: success state is set before the success handler runs.
    controller.downloadAttachmentState.value = Right<Failure, Success>(success);
    controller.handleDownloadAttachmentSuccessForTest(success);

    final state = controller.downloadAttachmentState.value;
    expect(state, isA<Right>());
    final successState = (state as Right).value;
    expect(successState, isA<IdleDownloadAttachmentForWeb>());

    verify(downloadManager.createAnchorElementDownloadFileWeb(bytes, 'a.bin'))
        .called(1);
  });
}
