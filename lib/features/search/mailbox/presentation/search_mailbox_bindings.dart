
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/move_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/rename_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/search_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_controller.dart';

class SearchMailboxBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => SearchMailboxController(
      Get.find<GetAllMailboxInteractor>(),
      Get.find<RefreshAllMailboxInteractor>(),
      Get.find<SearchMailboxInteractor>(),
      Get.find<RenameMailboxInteractor>(),
      Get.find<MoveMailboxInteractor>(),
      Get.find<DeleteMultipleMailboxInteractor>(),
      Get.find<TreeBuilder>(),
      Get.find<VerifyNameInteractor>()
    ));
  }

  @override
  void bindingsDataSource() {}

  @override
  void bindingsDataSourceImpl() {}

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => SearchMailboxInteractor());
  }

  @override
  void bindingsRepository() {}

  @override
  void bindingsRepositoryImpl() {}

  void disposeBindings() {
    Get.delete<SearchMailboxController>();
  }
}