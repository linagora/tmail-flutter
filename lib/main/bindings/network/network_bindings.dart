import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:contact/data/network/contact_api.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart' as JmapHttpClient;
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_isolate_interceptors.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/features/login/data/utils/library_platform/app_auth_plugin/app_auth_plugin.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_isolate_worker.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/manage_account_api.dart';
import 'package:tmail_ui_user/features/session/data/network/session_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_isolate_worker.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';

class NetworkBindings extends Bindings {

  @override
  void dependencies() {
    _bindingDio();
    _bindingApi();
    _bindingIsolateWorker();
    _bindingConnection();
    _bindingException();
  }

  void _bindingBaseOption() {
    final headers = <String, dynamic>{
      HttpHeaders.acceptHeader: Constant.acceptHeaderDefault,
      HttpHeaders.contentTypeHeader: Constant.contentTypeHeaderDefault
    };
    Get.put(BaseOptions(headers: headers));
  }

  void _bindingDio() {
    _bindingBaseOption();
    Get.put(Dio(Get.find<BaseOptions>()));
    Get.put(Dio(Get.find<BaseOptions>()), tag: BindingTag.isoLateTag);
    Get.put(DioClient(Get.find<Dio>()));
    Get.put(DioClient(Get.find<Dio>(tag: BindingTag.isoLateTag)), tag: BindingTag.isoLateTag);
    Get.put(const FlutterAppAuth());
    Get.put(AppAuthWebPlugin());
    Get.put(OIDCHttpClient(Get.find<DioClient>()));
    Get.put(AuthenticationClientBase());
    _bindingInterceptors();
  }

  void _bindingInterceptors() {
    Get.put(DynamicUrlInterceptors());
    Get.put(AuthorizationIsolateInterceptors());
    Get.put(AuthorizationInterceptors(
        Get.find<Dio>(),
        Get.find<AuthenticationClientBase>(),
        Get.find<TokenOidcCacheManager>(),
        Get.find<AccountCacheManager>(),
    ));
    Get.find<Dio>(tag: BindingTag.isoLateTag).interceptors.add(Get.find<DynamicUrlInterceptors>());
    Get.find<Dio>(tag: BindingTag.isoLateTag).interceptors.add(Get.find<AuthorizationIsolateInterceptors>());
    Get.find<Dio>().interceptors.add(Get.find<DynamicUrlInterceptors>());
    Get.find<Dio>().interceptors.add(Get.find<AuthorizationInterceptors>());
    if (kDebugMode) {
      Get.find<Dio>().interceptors.add(LogInterceptor(requestBody: true));
      Get.find<Dio>(tag: BindingTag.isoLateTag).interceptors.add(LogInterceptor(requestBody: true));
    }
  }

  void _bindingApi() {
    Get.put(JmapHttpClient.HttpClient(Get.find<Dio>()));
    Get.put(DownloadClient(Get.find<DioClient>(), Get.find<CompressFileUtils>()));
    Get.put(DownloadManager(Get.find<DownloadClient>()));
    Get.put(MailboxAPI(Get.find<JmapHttpClient.HttpClient>()));
    Get.put(SessionAPI(Get.find<JmapHttpClient.HttpClient>()));
    Get.put(ThreadAPI(Get.find<JmapHttpClient.HttpClient>()));
    Get.put(EmailAPI(
      Get.find<JmapHttpClient.HttpClient>(),
      Get.find<DownloadManager>(),
      Get.find<DioClient>()));
    Get.put(ManageAccountAPI(Get.find<JmapHttpClient.HttpClient>()));
    Get.put(ContactAPI(Get.find<JmapHttpClient.HttpClient>()));
  }

  void _bindingConnection() {
    Get.put(Connectivity());
  }

  void _bindingException() {
    Get.put(RemoteExceptionThrower());
  }

  void _bindingIsolateWorker() {
    Get.put(ThreadIsolateWorker(
        Get.find<ThreadAPI>(),
        Get.find<EmailAPI>()));
    Get.put(MailboxIsolateWorker(
        Get.find<ThreadAPI>(),
        Get.find<EmailAPI>()));
  }
}