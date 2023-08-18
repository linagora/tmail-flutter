import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:contact/data/network/contact_api.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/data/network/mdn_api.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/features/login/data/utils/library_platform/app_auth_plugin/app_auth_plugin.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/network/spam_report_api.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/forwarding_api.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/identity_api.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/rule_filter_api.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/vacation_api.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/fcm_api.dart';
import 'package:tmail_ui_user/features/quotas/data/network/quotas_api.dart';
import 'package:tmail_ui_user/features/session/data/network/session_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:uuid/uuid.dart';

class NetworkBindings extends Bindings {

  @override
  void dependencies() {
    _bindingConnection();
    _bindingDio();
    _bindingApi();
    _bindingTransformer();
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
    Get.put(DioClient(Get.find<Dio>()));
    Get.put(const FlutterAppAuth());
    Get.put(AppAuthWebPlugin());
    Get.put(OIDCHttpClient(Get.find<DioClient>()));
    Get.put(AuthenticationClientBase());
    _bindingInterceptors();
  }

  void _bindingInterceptors() {
    Get.put(DynamicUrlInterceptors());
    Get.put(AuthorizationInterceptors(
        Get.find<Dio>(),
        Get.find<AuthenticationClientBase>(),
        Get.find<TokenOidcCacheManager>(),
        Get.find<AccountCacheManager>(),
    ));
    Get.find<Dio>().interceptors.add(Get.find<DynamicUrlInterceptors>());
    Get.find<Dio>().interceptors.add(Get.find<AuthorizationInterceptors>());
    if (kDebugMode) {
      Get.find<Dio>().interceptors.add(LogInterceptor(requestBody: true));
    }
  }

  void _bindingApi() {
    Get.put(HttpClient(Get.find<Dio>()));
    Get.put(DownloadClient(Get.find<DioClient>(), Get.find<CompressFileUtils>()));
    Get.put(DownloadManager(Get.find<DownloadClient>()));
    Get.put(MailboxAPI(Get.find<HttpClient>()));
    Get.put(SessionAPI(Get.find<HttpClient>()));
    Get.put(ThreadAPI(Get.find<HttpClient>()));
    Get.put(EmailAPI(
      Get.find<HttpClient>(),
      Get.find<DownloadManager>(),
      Get.find<DioClient>(),
      Get.find<Uuid>(),
    ));
    Get.put(RuleFilterAPI(Get.find<HttpClient>()));
    Get.put(VacationAPI(Get.find<HttpClient>()));
    Get.put(ContactAPI(Get.find<HttpClient>()));
    Get.put(IdentityAPI(Get.find<HttpClient>()));
    Get.put(MdnAPI(Get.find<HttpClient>()));
    Get.put(ForwardingAPI(Get.find<HttpClient>()));
    Get.put(QuotasAPI(Get.find<HttpClient>()));
    Get.put(FcmApi(Get.find<HttpClient>()));
    Get.put(SpamReportApi(Get.find<HttpClient>()));
  }

  void _bindingConnection() {
    Get.put(Connectivity());
  }

  void _bindingException() {
    Get.put(RemoteExceptionThrower());
  }

  void _bindingTransformer() {
    Get.put(const HtmlEscape());
    Get.put(HtmlTransform(Get.find<DioClient>()));
    Get.put(HtmlAnalyzer(Get.find<HtmlTransform>(), Get.find<HtmlEscape>()));
  }
}