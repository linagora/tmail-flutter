import 'package:core/core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/features/login/data/utils/library_platform/app_auth_plugin/app_auth_plugin.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/state_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_isolate_worker.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_manager.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_isolate_worker.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:worker_manager/worker_manager.dart';

class NetworkIsolateBindings extends Bindings {

  @override
  void dependencies() {
    _bindingDio();
    _bindingSharing();
    _bindingInterceptors();
    _bindingApi();
    _bindingIsolateWorker();
    _bindingTransformer();
  }

  void _bindingDio() {
    Get.put(Dio(Get.find<BaseOptions>()), tag: BindingTag.isolateTag);
    Get.put(DioClient(
      Get.find<Dio>(tag: BindingTag.isolateTag)),
      tag: BindingTag.isolateTag);
    Get.put(const FlutterAppAuth(), tag: BindingTag.isolateTag);
    Get.put(AppAuthWebPlugin(), tag: BindingTag.isolateTag);
    Get.put(
      AuthenticationClientBase(tag: BindingTag.isolateTag),
      tag: BindingTag.isolateTag);
  }

  void _bindingInterceptors() {
    Get.put(AuthorizationInterceptors(
      Get.find<Dio>(tag: BindingTag.isolateTag),
      Get.find<AuthenticationClientBase>(tag: BindingTag.isolateTag),
      Get.find<TokenOidcCacheManager>(tag: BindingTag.isolateTag),
      Get.find<AccountCacheManager>(tag: BindingTag.isolateTag),
      Get.find<IOSSharingManager>(tag: BindingTag.isolateTag),
    ), tag: BindingTag.isolateTag);
    Get.find<Dio>(tag: BindingTag.isolateTag).interceptors
      .add(Get.find<DynamicUrlInterceptors>());
    Get.find<Dio>(tag: BindingTag.isolateTag).interceptors
      .add(Get.find<AuthorizationInterceptors>(tag: BindingTag.isolateTag));
    if (BuildUtils.isDebugMode) {
      Get.find<Dio>(tag: BindingTag.isolateTag).interceptors
        .add(LogInterceptor(requestBody: true));
    }
  }

  void _bindingApi() {
    Get.put(HttpClient(
      Get.find<Dio>(tag: BindingTag.isolateTag)),
      tag: BindingTag.isolateTag);
    Get.put(DownloadClient(
      Get.find<DioClient>(tag: BindingTag.isolateTag),
      Get.find<CompressFileUtils>()), tag: BindingTag.isolateTag);
    Get.put(DownloadManager(
      Get.find<DownloadClient>(tag: BindingTag.isolateTag),
      Get.find<DeviceInfoPlugin>()), tag: BindingTag.isolateTag);
    Get.put(ThreadAPI(
      Get.find<HttpClient>(tag: BindingTag.isolateTag)),
      tag: BindingTag.isolateTag);
    Get.put(EmailAPI(
      Get.find<HttpClient>(tag: BindingTag.isolateTag),
      Get.find<DownloadManager>(tag: BindingTag.isolateTag),
      Get.find<DioClient>(tag: BindingTag.isolateTag),
      Get.find<Uuid>()
    ), tag: BindingTag.isolateTag);

  }

  void _bindingIsolateWorker() {
    Get.put(ThreadIsolateWorker(
      Get.find<ThreadAPI>(tag: PlatformInfo.isMobile ? BindingTag.isolateTag : null),
      Get.find<EmailAPI>(tag: PlatformInfo.isMobile ? BindingTag.isolateTag : null),
      Get.find<Executor>(),
    ));
    Get.put(MailboxIsolateWorker(
      Get.find<ThreadAPI>(tag: PlatformInfo.isMobile ? BindingTag.isolateTag : null),
      Get.find<EmailAPI>(tag: PlatformInfo.isMobile ? BindingTag.isolateTag : null),
      Get.find<Executor>(),
    ));
    Get.put(FileUploader(
      Get.find<DioClient>(tag: PlatformInfo.isMobile ? BindingTag.isolateTag : null),
      Get.find<Executor>(),
      Get.find<FileUtils>(),
    ));
  }

  void _bindingSharing() {
    Get.put(OIDCHttpClient(
      Get.find<DioClient>(tag: BindingTag.isolateTag)),
      tag: BindingTag.isolateTag);
    Get.put(IOSSharingManager(
      Get.find<KeychainSharingManager>(),
      Get.find<StateCacheManager>(),
      Get.find<TokenOidcCacheManager>(),
      Get.find<AuthenticationInfoCacheManager>(),
      Get.find<OidcConfigurationCacheManager>(),
      Get.find<OIDCHttpClient>(tag: BindingTag.isolateTag),
      Get.find<MailboxCacheManager>(),
    ), tag: BindingTag.isolateTag);
  }

  void _bindingTransformer() {
    Get.put(HtmlAnalyzer(
      Get.find<HtmlTransform>(),
      Get.find<FileUploader>(),
      Get.find<Uuid>(),
    ));
  }
}