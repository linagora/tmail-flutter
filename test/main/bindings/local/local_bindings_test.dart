import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/instance_manager.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/web_token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/main/bindings/local/local_bindings.dart';

import 'local_bindings_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FlutterSecureStorage>(),
  MockSpec<SharedPreferences>(),
  MockSpec<FileUtils>(),
])
void main() {
  late LocalBindings localBindings;

  setUp(() {
    localBindings = LocalBindings();
    Get.put<FlutterSecureStorage>(MockFlutterSecureStorage());
    Get.put<SharedPreferences>(MockSharedPreferences());
    Get.put<FileUtils>(MockFileUtils());
  });

  group('local bindings test:', () {
    test(
      'should inject WebTokenOidcCacheManager '
      'when platform is web',
    () {
      // arrange
      PlatformInfo.isTestingForWeb = true;
      localBindings.dependencies();
      
      // act
      final cacheManager = Get.find<TokenOidcCacheManager>();
      
      // assert
      expect(cacheManager, isInstanceOf<WebTokenOidcCacheManager>());
      PlatformInfo.isTestingForWeb = false;
    });

    test(
      'should inject TokenOidcCacheManager '
      'when platform is not web (default)',
    () {
      // arrange
      localBindings.dependencies();
      
      // act
      final cacheManager = Get.find<TokenOidcCacheManager>();
      
      // assert
      expect(cacheManager, isInstanceOf<TokenOidcCacheManager>());
    });
  });
}