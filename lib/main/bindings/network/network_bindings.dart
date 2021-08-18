import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart' as JmapHttpClient;
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/login/data/network/login_api.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/session/data/network/session_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';

class NetworkBindings extends Bindings {

  @override
  void dependencies() {
    _bindingDio();
    _bindingApi();
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
    _bindingInterceptors();
    Get.find<Dio>().interceptors.add(Get.find<DynamicUrlInterceptors>());
    Get.find<Dio>().interceptors.add(Get.find<AuthorizationInterceptors>());
    if (kDebugMode) {
      Get.find<Dio>().interceptors.add(LogInterceptor(requestBody: true));
    }
  }

  void _bindingInterceptors() {
    Get.put(DynamicUrlInterceptors());
    Get.put(AuthorizationInterceptors());
  }

  void _bindingApi() {
    Get.put(DioClient(Get.find<Dio>()));
    Get.put(JmapHttpClient.HttpClient(Get.find<Dio>()));
    Get.put(LoginAPI(Get.find<DioClient>()));
    Get.put(MailboxAPI(Get.find<JmapHttpClient.HttpClient>()));
    Get.put(SessionAPI(Get.find<JmapHttpClient.HttpClient>()));
    Get.put(ThreadAPI(Get.find<JmapHttpClient.HttpClient>()));
    Get.put(EmailAPI(Get.find<JmapHttpClient.HttpClient>()));
  }
}