
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/labels/add_list_label_to_list_emails_interactor.dart';
import 'package:tmail_ui_user/features/labels/presentation/delegates/add_list_label_to_list_emails_delegate.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/search/email/domain/usecases/refresh_changes_search_email_interactor.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';

class SearchEmailBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.put(SearchEmailController(
      Get.find<QuickSearchEmailInteractor>(),
      Get.find<SaveRecentSearchInteractor>(),
      Get.find<GetAllRecentSearchLatestInteractor>(),
      Get.find<SearchEmailInteractor>(),
      Get.find<SearchMoreEmailInteractor>(),
      Get.find<RefreshChangesSearchEmailInteractor>(),
    ));
    Get.put(AddListLabelToListEmailsDelegate(
      Get.find<LabelController>(),
      Get.find<AddListLabelToListEmailsInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {
  }

  @override
  void bindingsDataSourceImpl() {
  }

  @override
  void bindingsInteractor() {
  }

  @override
  void bindingsRepository() {
  }

  @override
  void bindingsRepositoryImpl() {
  }

  void disposeBindings() {
    Get.delete<SearchEmailController>();
  }
}