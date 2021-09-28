import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/login/data/repository/credential_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/repository/mailbox_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';

class MailboxBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CredentialRepositoryImpl(Get.find<SharedPreferences>()));
    Get.lazyPut<CredentialRepository>(() => Get.find<CredentialRepositoryImpl>());
    Get.lazyPut(() => DeleteCredentialInteractor(Get.find<CredentialRepository>()));
    Get.lazyPut(() => MailboxDataSourceImpl(Get.find<MailboxAPI>()));
    Get.lazyPut<MailboxDataSource>(() => Get.find<MailboxDataSourceImpl>());
    Get.lazyPut(() => MailboxCacheDataSourceImpl(Get.find<MailboxCacheManager>()));
    Get.lazyPut(() => MailboxRepositoryImpl({
      DataSourceType.network: Get.find<MailboxDataSource>(),
      DataSourceType.local: Get.find<MailboxCacheDataSourceImpl>(),
    }));
    Get.lazyPut<MailboxRepository>(() => Get.find<MailboxRepositoryImpl>());
    Get.lazyPut(() => GetAllMailboxInteractor(Get.find<MailboxRepository>()));
    Get.lazyPut(() => TreeBuilder());
    Get.put(MailboxController(
      Get.find<GetAllMailboxInteractor>(),
      Get.find<DeleteCredentialInteractor>(),
      Get.find<TreeBuilder>(),
      Get.find<ResponsiveUtils>()));
  }
}