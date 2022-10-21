
import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/caching/account_cache_client.dart';
import 'package:tmail_ui_user/features/caching/authentication_info_cache_client.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/caching/email_cache_client.dart';
import 'package:tmail_ui_user/features/caching/encryption_key_cache_client.dart';
import 'package:tmail_ui_user/features/caching/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/recent_login_url_cache_client.dart';
import 'package:tmail_ui_user/features/caching/recent_search_cache_client.dart';
import 'package:tmail_ui_user/features/caching/state_cache_client.dart';
import 'package:tmail_ui_user/features/caching/token_oidc_cache_client.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_login_url_cache_manager.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_search_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/encryption_key_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';

class LocalBindings extends Bindings {

  @override
  void dependencies() {
    _bindingDatabase();
    _bindingCaching();
  }

  void _bindingDatabase() {
    Get.put(DatabaseClient());
  }

  void _bindingCaching() {
    Get.put(MailboxCacheClient());
    Get.put(StateCacheClient());
    Get.put(MailboxCacheManager(Get.find<MailboxCacheClient>()));
    Get.put(EmailCacheClient());
    Get.put(EmailCacheManager(Get.find<EmailCacheClient>()));
    Get.put(RecentSearchCacheClient());
    Get.put(RecentSearchCacheManager(Get.find<RecentSearchCacheClient>()));
    Get.put(TokenOidcCacheClient());
    Get.put(TokenOidcCacheManager(Get.find<TokenOidcCacheClient>()));
    Get.put(AccountCacheClient());
    Get.put(AccountCacheManager(Get.find<AccountCacheClient>()));
    Get.put(EncryptionKeyCacheClient());
    Get.put(EncryptionKeyCacheManager(Get.find<EncryptionKeyCacheClient>()));
    Get.put(AuthenticationInfoCacheClient());
    Get.put(AuthenticationInfoCacheManager(Get.find<AuthenticationInfoCacheClient>()));
    Get.put(OidcConfigurationCacheManager(Get.find<SharedPreferences>()));
    Get.put(LanguageCacheManager(Get.find<SharedPreferences>()));
    Get.put(RecentLoginUrlCacheClient());
    Get.put(RecentLoginUrlCacheManager((Get.find<RecentLoginUrlCacheClient>())));
    Get.put(CachingManager(
      Get.find<MailboxCacheClient>(),
      Get.find<StateCacheClient>(),
      Get.find<EmailCacheClient>(),
      Get.find<RecentSearchCacheClient>(),
      Get.find<AccountCacheClient>(),
    ));
  }
}