import 'package:core/utils/file_utils.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/clients/composer_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/email_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/fcm_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/new_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/opened_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/sending_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/state_cache_client.dart';
import 'package:tmail_ui_user/features/delegation/data/datasource/ended_delegation_store_impl.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/ended_delegation_store.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/cleanup_ended_delegations_interactor.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_source.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/riverpod_active_account_source.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_manager.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

class DelegationBindings extends Bindings {
  @override
  void dependencies() {
    // Lives as long as activeAccountProvider, so a reader never outlives it. The only GetX
    // access to the shown account (ADR-0092).
    final source = RiverpodActiveAccountSource(appProviderContainer);
    Get.put<ActiveAccountSource>(source, permanent: true);
    Get.put<ActiveAccountWriter>(source, permanent: true);
    Get.put<ShownAccountLoadReporter>(source, permanent: true);
    Get.lazyPut<EndedDelegationStore>(_endedDelegationStore, fenix: true);
    Get.lazyPut<CleanupEndedDelegationsInteractor>(
      () => CleanupEndedDelegationsInteractor(Get.find<EndedDelegationStore>()),
      fenix: true,
    );
  }
}

EndedDelegationStore _endedDelegationStore() {
  return EndedDelegationStoreImpl(
    mailboxCacheClient: Get.find<MailboxCacheClient>(),
    emailCacheClient: Get.find<EmailCacheClient>(),
    stateCacheClient: Get.find<StateCacheClient>(),
    newEmailCacheClient: Get.find<NewEmailHiveCacheClient>(),
    openedEmailCacheClient: Get.find<OpenedEmailHiveCacheClient>(),
    sendingEmailCacheClient: Get.find<SendingEmailHiveCacheClient>(),
    fcmCacheClient: Get.find<FcmCacheClient>(),
    emailCacheManager: Get.find<EmailCacheManager>(),
    newEmailCacheManager: Get.find<NewEmailCacheManager>(),
    openedEmailCacheManager: Get.find<OpenedEmailCacheManager>(),
    keychainSharingManager: Get.find<KeychainSharingManager>(),
    fileUtils: Get.find<FileUtils>(),
    composerHiveCacheClient: Get.isRegistered<ComposerHiveCacheClient>()
        ? Get.find<ComposerHiveCacheClient>()
        : null,
  );
}
