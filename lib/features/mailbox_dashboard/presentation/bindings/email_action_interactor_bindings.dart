import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/add_a_label_to_an_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/remove_a_label_from_an_email_interactor.dart';

class EmailActionInteractorBindings extends Bindings {

  final EmailRepository _emailRepository;

  EmailActionInteractorBindings(this._emailRepository);

  @override
  void dependencies() {
    Get.lazyPut(() => AddALabelToAnEmailInteractor(_emailRepository));
    Get.lazyPut(() => RemoveALabelFromAnEmailInteractor(_emailRepository));
  }
}