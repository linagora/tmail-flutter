import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/state/display_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/state/mailbox_state.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class MailboxController extends GetxController {

  final GetAllMailboxInteractor _getAllMailboxInteractor;

  final mailboxState = Right<Failure, Success>(UIState.idle).obs;

  // var mailboxList = <PresentationMailbox>[].obs;
  // var mailboxHasRoleList = <PresentationMailbox>[].obs;
  // var mailboxFolderList = <PresentationMailbox>[].obs;
  // var mailboxFolderTreeList = <MailboxTree>[].obs;

  var displayMode = DisplayMode.TREE_VIEW.obs;

  MailboxController(this._getAllMailboxInteractor);

  @override
  void onReady() {
    super.onReady();
    getAllMailboxAction();
  }
  
  void getAllMailboxAction() async {
    final AccountId accountId = AccountId(Id('3ce33c876a726662c627746eb9537a1d13c2338193ef27bd051a3ce5c0fe5b12'));

    _getAllMailboxInteractor.execute(accountId).listen((event) { })

    // mailboxState.value = MailboxState(Right(MailboxStateLoadingAction()));
    // await _getAllMailboxInteractor.execute(accountId)
    //   .then((response) => response.fold(
    //     (failure) => mailboxState.value = MailboxState(Left(failure)),
    //     (success) {
    //       mailboxState.value = MailboxState(Right(success));
    //       mailboxList.value = success is GetAllMailboxViewState ? success.mailboxList : [];
    //       _setListMailboxHasRole(mailboxList);
    //       _setListMailboxOfMyFolder(mailboxList);
    //     }));
  }

  // void _setListMailboxHasRole(List<PresentationMailbox> mailboxesList) {
  //   mailboxHasRoleList.value = mailboxesList
  //     .where((mailbox) => mailbox.isMailboxRole())
  //     .toList();
  //
  //   final mailboxInBox = mailboxHasRoleList.where((mailbox) => mailbox.role?.value == 'inbox').toList();
  //   if (mailboxInBox.isNotEmpty) {
  //     selectMailbox(mailboxInBox.first);
  //   }
  // }

  // void _setListMailboxOfMyFolder(List<PresentationMailbox> mailboxesList) {
  //   final listMailboxFolder = mailboxesList
  //     .where((mailbox) => !mailbox.isMailboxRole())
  //     .toList();
  //
  //   setMailboxFolderTree(mailboxesList, listMailboxFolder);
  // }

  // void setMailboxFolderTree(List<PresentationMailbox> mailboxesList, List<PresentationMailbox> listMailboxFolder) {
  //   final listMailboxTree = listMailboxFolder.map((mailbox) => MailboxTree(mailbox, [])).toList();
  //
  //   final resultTreeList = convertMailboxToTree(listMailboxTree);
  //
  //   mailboxFolderTreeList.value = resultTreeList;
  // }

  bool findMailboxInParent(List<MailboxTree> listChildMailboxTree, MailboxId mailboxId) {
    return listChildMailboxTree.where((item) => item.item.id == mailboxId).toList().isNotEmpty;
  }

  List<MailboxTree> convertMailboxToTree(List<MailboxTree> mailboxTreeList) {
    final arrMap = Map<MailboxId, MailboxTree>.fromIterable(
      mailboxTreeList,
      key: (mailboxTree) => mailboxTree.item.id,
      value: (mailboxTree) => mailboxTree);

    final List<MailboxTree> tree = [];

    mailboxTreeList.forEach((item) {
      if (item.hasParentId()) {
        final parentItem = arrMap[item.item.parentId];
        if (parentItem != null
            && parentItem.item.id != item.item.id
            && !findMailboxInParent(parentItem.childrenItems as List<MailboxTree>, item.item.id)) {
          parentItem.childrenItems.add(item);
        } else {
          tree.add(item);
        }
      } else {
        tree.add(item);
      }
    });

    return tree;
  }

  void closeMailboxScreen() {
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  void selectMailbox(PresentationMailbox mailboxSelected) {
    mailboxHasRoleList.value = mailboxHasRoleList.map((mailbox) => mailbox.id == mailboxSelected.id
        ? mailbox.toMailboxSelected(SelectMode.ACTIVE)
        : mailbox.toMailboxSelected(SelectMode.INACTIVE))
      .toList();
  }
}