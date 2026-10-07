import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/add_a_label_to_an_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/remove_a_label_from_an_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/labels/add_list_label_to_list_emails_interactor.dart';

class EmailActionInteractorBindings extends Bindings {

  final EmailRepository _emailRepository;

  EmailActionInteractorBindings(this._emailRepository);

  @override
  void dependencies() {
    // Created eagerly so they belong to the dashboard route. A lazy instance is
    // first resolved inside the label dialog on touch layouts, so GetX links it
    // to that dialog and deletes it when the dialog closes.
    Get.put(AddALabelToAnEmailInteractor(_emailRepository));
    Get.put(RemoveALabelFromAnEmailInteractor(_emailRepository));
    Get.lazyPut(() => AddListLabelToListEmailsInteractor(_emailRepository));
  }
}
