import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/expand_folder_trigger_scrollable_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/expand_mode_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/duplicate_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/name_with_space_only_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/special_character_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/mailbox_creator_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/new_mailbox_arguments.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class MailboxCreatorController extends BaseController
    with ExpandFolderTriggerScrollableMixin {

  final VerifyNameInteractor _verifyNameInteractor;

  final selectedMailbox = Rxn<PresentationMailbox>();
  final newNameMailbox = Rxn<String>();
  final isFolderModalEnabled = RxBool(false);
  bool _createdMailbox = false;

  final personalMailboxTree = MailboxTree(MailboxNode.root()).obs;
  final defaultMailboxTree = MailboxTree(MailboxNode.root()).obs;

  final FocusNode nameInputFocusNode = FocusNode();
  final TextEditingController nameInputController = TextEditingController();
  final ScrollController listFolderScrollController = ScrollController();

  List<String> listMailboxNameAsStringExist = <String>[];

  MailboxCreatorController(this._verifyNameInteractor);

  void setNewNameMailbox(String newName) => newNameMailbox.value = newName;

  @override
  void onInit() {
    super.onInit();
    MailboxCreatorArguments? arguments = Get.arguments;
    if (arguments != null) {
      personalMailboxTree.value = arguments.personalMailboxTree;
      defaultMailboxTree.value = arguments.defaultMailboxTree;
      selectedMailbox.value = arguments.selectedMailbox;
      _createListMailboxNameAsStringInMailboxLocation();
    }
  }

  @override
  void onClose() {
    listMailboxNameAsStringExist = [];
    _createdMailbox = false;
    nameInputFocusNode.dispose();
    nameInputController.dispose();
    listFolderScrollController.dispose();
    super.onClose();
  }

  MailboxNode? _findMailboxNodeById(MailboxId mailboxId) {
    final mailboxNode = defaultMailboxTree.value.findNode((node) => node.item.id == mailboxId)
     ?? personalMailboxTree.value.findNode((node) => node.item.id == mailboxId);
    return mailboxNode;
  }

  void _createListMailboxNameAsStringInMailboxLocation() {
    if (selectedMailbox.value == null) {
      final allChildrenAtMailboxLocation = (defaultMailboxTree.value.root.childrenItems ?? <MailboxNode>[])
        + (personalMailboxTree.value.root.childrenItems ?? <MailboxNode>[]);
      if (allChildrenAtMailboxLocation.isNotEmpty) {
        listMailboxNameAsStringExist = allChildrenAtMailboxLocation
            .where((mailboxNode) => mailboxNode.nameNotEmpty)
            .map((mailboxNode) => mailboxNode.mailboxNameAsString)
            .toList();
      }  else {
        listMailboxNameAsStringExist = [];
      }
    } else {
      final mailboxNodeLocation = _findMailboxNodeById(selectedMailbox.value!.id);
      if (mailboxNodeLocation != null && mailboxNodeLocation.childrenItems?.isNotEmpty == true) {
        final allChildrenAtMailboxLocation =  mailboxNodeLocation.childrenItems!;
        listMailboxNameAsStringExist = allChildrenAtMailboxLocation
            .where((mailboxNode) => mailboxNode.nameNotEmpty)
            .map((mailboxNode) => mailboxNode.mailboxNameAsString)
            .toList();
      } else {
        listMailboxNameAsStringExist = [];
      }
    }
  }

  String? getErrorInputNameString(BuildContext context) {
    final nameMailbox = newNameMailbox.value;
    final canCheckNameString = _createdMailbox && nameInputFocusNode.hasFocus == false;

    return _verifyNameInteractor.execute(
        nameMailbox,
        [
          if (canCheckNameString)
            EmptyNameValidator(),
          NameWithSpaceOnlyValidator(),
          DuplicateNameValidator(listMailboxNameAsStringExist),
          SpecialCharacterValidator()
        ]
    ).fold(
      (failure) {
        if (failure is VerifyNameFailure) {
          _createdMailbox = false;
          return failure.getMessage(context);
        } else {
          return null;
        }
      },
      (success) => null
    );
  }

  void openFolderModal(BuildContext context) {
    nameInputFocusNode.unfocus();

    if (!responsiveUtils.isMobile(context)) {
      isFolderModalEnabled.value = true;
    }
  }

  void selectMailboxLocation(MailboxNode? mailboxDestination) {
    isFolderModalEnabled.value = false;
    selectedMailbox.value = mailboxDestination?.item;
    _createListMailboxNameAsStringInMailboxLocation();
  }

  void createNewMailbox(BuildContext context) {
    nameInputFocusNode.unfocus();

    final nameMailbox = newNameMailbox.value;
    final nameValidated = getErrorInputNameString(context);

    if (nameValidated == null) {
      _createdMailbox = true;
    }

    if (nameMailbox != null && nameMailbox.isNotEmpty && _createdMailbox) {
      final newMailboxArguments = NewMailboxArguments(
        MailboxName(nameMailbox),
        mailboxLocation: selectedMailbox.value);
      popBack(result: newMailboxArguments);
    } else {
      newNameMailbox.refresh();
    }
  }

  void toggleFolder(MailboxNode selectedMailboxNode, GlobalKey itemKey) {
    final newExpandMode = selectedMailboxNode.expandMode.toggle();

    if (defaultMailboxTree.value.updateExpandedNode(selectedMailboxNode, newExpandMode) != null) {
      defaultMailboxTree.refresh();
      triggerScrollWhenExpandFolder(
        selectedMailboxNode.expandMode,
        itemKey,
        listFolderScrollController,
      );
    }

    if (personalMailboxTree.value.updateExpandedNode(selectedMailboxNode, newExpandMode) != null) {
      personalMailboxTree.refresh();
      triggerScrollWhenExpandFolder(
        selectedMailboxNode.expandMode,
        itemKey,
        listFolderScrollController,
      );
    }
  }

  void closeView() {
    nameInputFocusNode.unfocus();
    popBack();
  }
}