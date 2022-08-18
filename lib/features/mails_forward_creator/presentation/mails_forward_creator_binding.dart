import 'package:contact/data/datasource/auto_complete_datasource.dart';
import 'package:contact/data/datasource_impl/tmail_contact_datasource_impl.dart';
import 'package:contact/data/network/contact_api.dart';
import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/state_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/repository/mailbox_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/autocomplete_bindings.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_controller.dart';

class MailsForwardCreatorBindings extends BaseBindings {

  @override
  void dependencies() {
    _bindingsUtils();
    super.dependencies();
  }

  void _bindingsUtils() {
    Get.lazyPut(() => AutoCompleteBindings());
  }

  @override
  void bindingsController() {
    Get.lazyPut(() => RulesFilterCreatorController(
        Get.find<VerifyNameInteractor>(),
        Get.find<GetAllMailboxInteractor>(),
        Get.find<TreeBuilder>()
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<AutoCompleteDataSource>(() => Get.find<TMailContactDataSourceImpl>());
    Get.lazyPut<StateDataSource>(() => Get.find<StateDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => TMailContactDataSourceImpl(Get.find<ContactAPI>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => VerifyNameInteractor());
    Get.lazyPut(() => GetAllMailboxInteractor(Get.find<MailboxRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<MailboxRepository>(() => Get.find<MailboxRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => MailboxRepositoryImpl(
      {
        DataSourceType.network: Get.find<MailboxDataSource>(),
        DataSourceType.local: Get.find<MailboxCacheDataSourceImpl>()
      },
      Get.find<StateDataSource>(),
    ));
  }
}