import 'dart:convert';

import 'package:model/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/data/utils/login_constant.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class CredentialRepositoryImpl extends CredentialRepository {

  final SharedPreferences sharedPreferences;
  final AuthenticationInfoCacheManager _authenticationInfoCacheManager;

  CredentialRepositoryImpl(
    this.sharedPreferences,
    this._authenticationInfoCacheManager
  );

  @override
  Future<Uri> getBaseUrl() async {
    return Uri.parse(sharedPreferences.getString(LoginConstant.keyBaseUrl) ?? '');
  }

  @override
  Future saveBaseUrl(Uri baseUrl) async {
    await sharedPreferences.setString(LoginConstant.keyBaseUrl, baseUrl.toString());
  }

  @override
  Future removeBaseUrl() async {
    await sharedPreferences.remove(LoginConstant.keyBaseUrl);
  }

  @override
  Future<UserProfile> getUserProfile() async {
    final json = sharedPreferences.getString(LoginConstant.keyUserProfile) ?? '';
    Map<String, dynamic> mapObject = jsonDecode(json);
    return UserProfileResponse.fromJson(mapObject).toUserProfile();
  }

  @override
  Future removeUserProfile() async {
    await sharedPreferences.remove(LoginConstant.keyUserProfile);
  }

  @override
  Future saveUserProfile(UserProfile userProfile) async {
    final userProfileResponse = userProfile.toUserProfileResponse();
    final json = jsonEncode(userProfileResponse.toJson());
    await sharedPreferences.setString(LoginConstant.keyUserProfile, json);
  }

  @override
  Future<void> storeAuthenticationInfo(AuthenticationInfoCache authenticationInfoCache) {
    return _authenticationInfoCacheManager.storeAuthenticationInfo(authenticationInfoCache);
  }

  @override
  Future<AuthenticationInfoCache?> getAuthenticationInfoStored() {
    return _authenticationInfoCacheManager.getAuthenticationInfoStored();
  }

  @override
  Future<void> removeAuthenticationInfo() {
    return _authenticationInfoCacheManager.removeAuthenticationInfo();
  }
}