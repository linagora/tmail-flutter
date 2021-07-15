import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/state/mailbox_state.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class MailboxController extends GetxController {

  final GetAllMailboxInteractor _getAllMailboxInteractor;

  var mailboxState = MailboxState(Right(MailboxStateInitAction())).obs;

  var mailboxList = <Mailbox>[].obs;
  var mailboxHasRoleList = <Mailbox>[].obs;
  var mailboxMyFolderList = <Mailbox>[].obs;

  MailboxController(this._getAllMailboxInteractor);

  @override
  void onReady() {
    super.onReady();
    getAllMailboxAction();
  }
  
  void getAllMailboxAction() async {
    final AccountId accountId = AccountId(Id('3ce33c876a726662c627746eb9537a1d13c2338193ef27bd051a3ce5c0fe5b12'));

    mailboxState.value = MailboxState(Right(MailboxStateLoadingAction()));
    await _getAllMailboxInteractor.execute(accountId)
      .then((response) => response.fold(
        (failure) => mailboxState.value = MailboxState(Left(failure)),
        (success) {
          mailboxState.value = MailboxState(Right(success));
          mailboxList.value = success is GetAllMailboxViewState ? success.mailboxList : [];
          _setListMailboxHasRole(mailboxList);
          _setListMailboxOfMyFolder(mailboxList);
        }));
  }

  void _setListMailboxHasRole(List<Mailbox> mailboxesList) {
    mailboxHasRoleList.value = mailboxesList
      .where((mailbox) => mailbox.isMailboxRole())
      .toList();

    final mailboxInBox = mailboxHasRoleList.where((mailbox) => mailbox.role?.value == 'inbox').toList();
    if (mailboxInBox.isNotEmpty) {
      selectMailbox(mailboxInBox.first);
    }
  }

  void _setListMailboxOfMyFolder(List<Mailbox> mailboxesList) {
    final listMailboxOfMyFolder = mailboxesList
      .where((mailbox) => !mailbox.isMailboxRole())
      .toList();

    mailboxMyFolderList.value = listMailboxOfMyFolder
      .map((mailbox) => mailbox.toMailboxParent(mailbox.getNameMailboxFolderHasParentId(mailboxesList)))
      .toList();
  }

  void closeMailboxScreen() {
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  void selectMailbox(Mailbox mailboxSelected) {
    mailboxHasRoleList.value = mailboxHasRoleList.map((mailbox) => mailbox.id == mailboxSelected.id
        ? mailbox.toMailboxSelected(SelectMode.ACTIVE)
        : mailbox.toMailboxSelected(SelectMode.INACTIVE))
      .toList();
  }
}