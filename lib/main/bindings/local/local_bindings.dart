
import 'package:core/utils/file_utils.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/caching/clients/account_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/authentication_info_cache_client.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/caching/clients/detailed_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/email_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/encryption_key_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/fcm_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/hive_cache_version_client.dart';
import 'package:tmail_ui_user/features/caching/clients/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/opened_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/recent_login_url_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/recent_login_username_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/recent_search_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/state_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/subscription_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/token_oidc_cache_client.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_login_url_cache_manager.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_login_username_cache_manager.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_search_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/encryption_key_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/local/share_preference_spam_report_data_source.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/detailed_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/detailed_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_worker_queue.dart';
import 'package:tmail_ui_user/features/push_notification/data/local/fcm_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';

class LocalBindings extends Bindings {

  @override
  void dependencies() {
    _bindingException();
    _bindingCaching();
    _bindingWorkerQueue();
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
    Get.put(RecentLoginUsernameCacheClient());
    Get.put(RecentLoginUsernameCacheManager(Get.find<RecentLoginUsernameCacheClient>()));
    Get.put(FCMSubscriptionCacheClient());
    Get.put(FcmCacheClient());
    Get.put(FCMCacheManager(Get.find<FcmCacheClient>(),Get.find<FCMSubscriptionCacheClient>()));
    Get.put(HiveCacheVersionClient(Get.find<SharedPreferences>(), Get.find<CacheExceptionThrower>()));
    Get.put(DetailedEmailHiveCacheClient());
    Get.put(DetailedEmailCacheManager(Get.find<DetailedEmailHiveCacheClient>(), Get.find<FileUtils>()));
    Get.put(OpenedEmailHiveCacheClient());
    Get.put(OpenedEmailCacheManager(Get.find<OpenedEmailHiveCacheClient>(), Get.find<FileUtils>()));
    Get.put(CachingManager(
      Get.find<MailboxCacheClient>(),
      Get.find<StateCacheClient>(),
      Get.find<EmailCacheClient>(),
      Get.find<RecentSearchCacheClient>(),
      Get.find<AccountCacheClient>(),
      Get.find<FcmCacheClient>(),
      Get.find<FCMSubscriptionCacheClient>(),
      Get.find<HiveCacheVersionClient>()
    ));
    Get.put(SharePreferenceSpamReportDataSource(Get.find<SharedPreferences>()));
  }

  void _bindingException() {
    Get.put(CacheExceptionThrower());
  }

  void _bindingWorkerQueue() {
    Get.put(DetailedEmailCacheWorkerQueue());
    Get.put(OpenedEmailCacheWorkerQueue());
  }
}