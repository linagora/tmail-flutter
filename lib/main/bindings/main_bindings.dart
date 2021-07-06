// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2020 LINAGORA
//
// This program is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later version,
// provided you comply with the Additional Terms applicable for LinShare software by
// Linagora pursuant to Section 7 of the GNU Affero General Public License,
// subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
// display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
// the words “You are using the Free and Open Source version of LinShare™, powered by
// Linagora © 2009–2020. Contribute to Linshare R&D by subscribing to an Enterprise
// offer!”. You must also retain the latter notice in all asynchronous messages such as
// e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
// http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
// infringing Linagora intellectual property rights over its trademarks and commercial
// brands. Other Additional Terms apply, see
// <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
// for more details.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more details.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
//  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
//  the Additional Terms applicable to LinShare software.

import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/login/data/datasource/atuthentitcation_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/authentication_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/network/login_http_client.dart';
import 'package:tmail_ui_user/features/login/data/repository/authentication_repository_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/credential_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authentication_user_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_credential_interactor.dart';

class MainBindings extends Bindings {
  @override
  void dependencies() {
    _bindingSharePreference();
    _bindingAppImagePaths();
    _bindingResponsiveManager();
    _bindingDio();
    _bindingRemoteExceptionThrower();
    _bindingNetwork();
    _bindingDataSourceImpl();
    _bindingDataSource();
    _bindingRepositoryImpl();
    _bindingRepository();
    _bindingInteractor();
  }

  void _bindingAppImagePaths() {
    Get.put(ImagePaths());
  }

  void _bindingResponsiveManager() {
    Get.put(ResponsiveUtils());
  }

  void _bindingDio() {
    Get.put(Dio());
    _bindingInterceptors();
    Get.find<Dio>().interceptors.add(Get.find<DynamicUrlInterceptors>());
    if (kDebugMode) {
      Get.find<Dio>().interceptors.add(LogInterceptor(requestBody: true));
    }
  }

  void _bindingInterceptors() {
    Get.put(DynamicUrlInterceptors());
  }

  void _bindingNetwork() {
    Get.put(DioClient(Get.find<Dio>()));
    Get.lazyPut(() => LoginHttpClient(Get.find<DioClient>()));
  }

  void _bindingRemoteExceptionThrower() {
    Get.put(RemoteExceptionThrower());
  }

  void _bindingSharePreference() {
    Get.putAsync(() async => await SharedPreferences.getInstance());
  }

  void _bindingDataSource() {
    Get.lazyPut<AuthenticationDataSource>(() => Get.find<AuthenticationDataSourceImpl>());
  }

  void _bindingDataSourceImpl() {
    Get.lazyPut(() => AuthenticationDataSourceImpl(
      Get.find<LoginHttpClient>(),
      Get.find<RemoteExceptionThrower>()));
  }

  void _bindingRepository() {
    Get.lazyPut<CredentialRepository>(() => Get.find<CredentialRepositoryImpl>());
    Get.lazyPut<AuthenticationRepository>(() => Get.find<AuthenticationRepositoryImpl>());
  }

  void _bindingRepositoryImpl() {
    Get.lazyPut(() => CredentialRepositoryImpl(Get.find<SharedPreferences>()));
    Get.lazyPut(() => AuthenticationRepositoryImpl(Get.find<AuthenticationDataSource>()));
  }

  void _bindingInteractor() {
    Get.lazyPut(() => AuthenticationInteractor(
      Get.find<AuthenticationRepository>(),
      Get.find<CredentialRepository>()));
    Get.lazyPut(() => GetCredentialInteractor(
      Get.find<CredentialRepository>()
    ));
  }
}