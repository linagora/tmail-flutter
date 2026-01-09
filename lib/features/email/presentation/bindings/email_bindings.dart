import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/add_a_label_to_an_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/remove_a_label_from_an_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/store_opened_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/email_interactor_bindings.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';

class EmailBindings extends Bindings {
  final EmailId? currentEmailId;

  EmailBindings({this.currentEmailId});

  String? get tag => currentEmailId?.id.value;

  void _bindingsController() {
    Get.put(SingleEmailController(
      Get.find<GetEmailContentInteractor>(),
      Get.find<MarkAsEmailReadInteractor>(),
      Get.find<MarkAsStarEmailInteractor>(),
      Get.find<GetAllIdentitiesInteractor>(),
      Get.find<StoreOpenedEmailInteractor>(),
      Get.find<AddALabelToAnEmailInteractor>(),
      Get.find<RemoveALabelFromAnEmailInteractor>(),
      Get.find<PrintEmailInteractor>(),
      currentEmailId: currentEmailId,
    ), tag: tag);
  }

  @override
  void dependencies() {
    EmailInteractorBindings().dependencies();
    _bindingsController();
  }
}