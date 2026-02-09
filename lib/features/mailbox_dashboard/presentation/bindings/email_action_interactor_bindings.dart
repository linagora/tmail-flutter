import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/labels/add_list_label_to_list_emails_interactor.dart';

class EmailActionInteractorBindings extends Bindings {
  final EmailRepository _emailRepository;

  EmailActionInteractorBindings(this._emailRepository);

  @override
  void dependencies() {
    Get.put(AddListLabelToListEmailsInteractor(_emailRepository));
  }
}
