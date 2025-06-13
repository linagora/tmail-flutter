
import 'package:core/utils/platform_info.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/clients/account_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/encryption_key_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/token_oidc_cache_client.dart';
import 'package:tmail_ui_user/features/caching/interactions/isar/isar_token_oidc_collection_interaction.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/encryption_key_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/isar_token_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/manager/token_cache_manager.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';

class LocalIsolateBindings extends Bindings {

  @override
  void dependencies() {
    _bindingCaching();
  }

  void _bindingCaching() {
    Get.put<TokenCacheManager>(
      PlatformInfo.isAndroid
        ? Get.find<IsarTokenCacheManager>()
        : Get.find<TokenOidcCacheManager>(),
      tag: BindingTag.isolateTag,
    );
    if (PlatformInfo.isAndroid) {
      Get.put(IsarTokenOidcCollectionInteraction(), tag: BindingTag.isolateTag);
      Get.put(
        IsarTokenCacheManager(
          Get.find<IsarTokenOidcCollectionInteraction>(
            tag: BindingTag.isolateTag,
          ),
        ),
        tag: BindingTag.isolateTag,
      );
    } else {
      Get.put(TokenOidcCacheClient(), tag: BindingTag.isolateTag);
      Get.put(TokenOidcCacheManager(
        Get.find<TokenOidcCacheClient>(tag: BindingTag.isolateTag)),
        tag: BindingTag.isolateTag,
      );
    }
    Get.put(AccountCacheClient(), tag: BindingTag.isolateTag);
    Get.put(AccountCacheManager(
      Get.find<AccountCacheClient>(tag: BindingTag.isolateTag)),
      tag: BindingTag.isolateTag
    );
    Get.put(EncryptionKeyCacheClient(), tag: BindingTag.isolateTag);
    Get.put(EncryptionKeyCacheManager(
      Get.find<EncryptionKeyCacheClient>(tag: BindingTag.isolateTag)),
      tag: BindingTag.isolateTag
    );
  }
}