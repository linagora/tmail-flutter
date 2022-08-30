import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart' as JmapHttpClient;
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_isolate_worker.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_isolate_worker.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:worker_manager/worker_manager.dart';

class NetworkIsolateBindings extends Bindings {

  @override
  void dependencies() {
    _bindingDio();
    _bindingApi();
    _bindingIsolateWorker();
  }

  void _bindingDio() {
    final dio = Get.put(Dio(Get.find<BaseOptions>()), tag: BindingTag.isolateTag);
    Get.put(DioClient(dio), tag: BindingTag.isolateTag);
    _bindingInterceptors(dio);
  }

  void _bindingInterceptors(Dio dio) {
    Get.put(AuthorizationInterceptors(
      dio,
      Get.find<AuthenticationClientBase>(),
      Get.find<TokenOidcCacheManager>(),
      Get.find<AccountCacheManager>(),
    ), tag: BindingTag.isolateTag);
    dio.interceptors.add(Get.find<DynamicUrlInterceptors>());
    dio.interceptors.add(Get.find<AuthorizationInterceptors>(tag: BindingTag.isolateTag));
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(requestBody: true));
    }
  }

  void _bindingApi() {
    final JmapHttpClient.HttpClient httpClient = Get.put(JmapHttpClient.HttpClient(Get.find<Dio>(tag: BindingTag.isolateTag)), tag: BindingTag.isolateTag);
    Get.put(DownloadClient(Get.find<DioClient>(tag: BindingTag.isolateTag), Get.find<CompressFileUtils>()), tag: BindingTag.isolateTag);
    Get.put(DownloadManager(Get.find<DownloadClient>(tag: BindingTag.isolateTag)), tag: BindingTag.isolateTag);
    Get.put(ThreadAPI(httpClient), tag: BindingTag.isolateTag);
    Get.put(EmailAPI(
      httpClient,
      Get.find<DownloadManager>(tag: BindingTag.isolateTag),
      Get.find<DioClient>(tag: BindingTag.isolateTag)), tag: BindingTag.isolateTag);
  }

  void _bindingIsolateWorker() {
    Get.put(Executor());
    Get.put(ThreadIsolateWorker(
      Get.find<ThreadAPI>(tag: BindingTag.isolateTag),
      Get.find<EmailAPI>(tag: BindingTag.isolateTag),
      Get.find<Executor>(),
    ));
    Get.put(MailboxIsolateWorker(
      Get.find<ThreadAPI>(tag: BindingTag.isolateTag),
      Get.find<EmailAPI>(tag: BindingTag.isolateTag),
      Get.find<Executor>(),
    ));
  }
}