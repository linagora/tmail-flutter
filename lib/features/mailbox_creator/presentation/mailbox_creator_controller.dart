
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/duplicate_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/special_character_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/mailbox_creator_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/new_mailbox_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class MailboxCreatorController extends BaseController {

  final VerifyNameInteractor _verifyNameInteractor;

  final selectedMailbox = Rxn<PresentationMailbox>();
  final newNameMailbox = Rxn<String>();

  final nameInputFocusNode = FocusNode();

  AccountId? accountId;
  MailboxTree? folderMailboxTree;
  MailboxTree? defaultMailboxTree;
  List<String> listMailboxNameAsStringExist = <String>[];

  MailboxCreatorController(
      this._verifyNameInteractor,
  );

  void setNewNameMailbox(String newName) => newNameMailbox.value = newName;

  @override
  void onReady() {
    super.onReady();
    final arguments = Get.arguments;
    if (arguments is MailboxCreatorArguments) {
      folderMailboxTree = arguments.folderMailboxTree;
      defaultMailboxTree = arguments.defaultMailboxTree;
      accountId = arguments.accountId;
      log('MailboxCreatorController::onReady(): defaultMailboxTree: $defaultMailboxTree');
      log('MailboxCreatorController::onReady(): folderMailboxTree: $folderMailboxTree');
      _createListMailboxNameAsStringInMailboxLocation();
    }
  }

  @override
  void onDone() {
  }

  @override
  void onError(error) {}

  @override
  void onClose() {
    nameInputFocusNode.dispose();
    super.onClose();
  }

  bool isCreateMailboxValidated(BuildContext context) {
    final nameValidated = getErrorInputNameString(context);

    if (!nameInputFocusNode.hasFocus && newNameMailbox.value == null) {
      return false;
    }

    if (nameValidated?.isNotEmpty == true) {
      return false;
    }
    return true;
  }

  void _createListMailboxNameAsStringInMailboxLocation() {
    if (selectedMailbox.value == null) {
      final allChildrenAtMailboxLocation = (defaultMailboxTree?.root.childrenItems ?? <MailboxNode>[]) + (folderMailboxTree?.root.childrenItems ?? <MailboxNode>[]);
      if (allChildrenAtMailboxLocation.isNotEmpty) {
        listMailboxNameAsStringExist = allChildrenAtMailboxLocation
            .where((mailboxNode) => mailboxNode.item.name != null && mailboxNode.item.name?.name.isNotEmpty == true)
            .map((mailboxNode) => mailboxNode.item.name!.name)
            .toList();
      }
    } else {
      final mailboxNodeLocation = defaultMailboxTree?.findNode((node) => node.item.id == selectedMailbox.value!.id)
          ?? folderMailboxTree?.findNode((node) => node.item.id == selectedMailbox.value!.id);
      if (mailboxNodeLocation != null && mailboxNodeLocation.childrenItems?.isNotEmpty == true) {
        final allChildrenAtMailboxLocation =  mailboxNodeLocation.childrenItems!;
        listMailboxNameAsStringExist = allChildrenAtMailboxLocation
            .where((mailboxNode) => mailboxNode.item.name != null && mailboxNode.item.name?.name.isNotEmpty == true)
            .map((mailboxNode) => mailboxNode.item.name!.name)
            .toList();
      }
    }

    log('MailboxCreatorController::_createListMailboxNameAsStringInMailboxLocation(): ${listMailboxNameAsStringExist.toString()}');
  }

  String? getErrorInputNameString(BuildContext context) {
    final nameMailbox = newNameMailbox.value;

    if (!nameInputFocusNode.hasFocus && nameMailbox == null) {
      return null;
    }

    return _verifyNameInteractor.execute(
        nameMailbox,
        [
          EmptyNameValidator(),
          DuplicateNameValidator(listMailboxNameAsStringExist),
          SpecialCharacterValidator(),
        ]
    ).fold(
      (failure) {
        if (failure is VerifyNameFailure) {
          return failure.getMessage(context);
        } else {
          return null;
        }
      },
      (success) => null
    );
  }

  void selectMailboxLocation(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (accountId != null) {
      final destinationMailbox = await push(
          AppRoutes.DESTINATION_PICKER,
          arguments: DestinationPickerArguments(accountId!, MailboxActions.create)
      );

      selectedMailbox.value = destinationMailbox;
      _createListMailboxNameAsStringInMailboxLocation();
    }
  }

  void createNewMailbox(BuildContext context) {
    FocusScope.of(context).unfocus();
    final nameMailbox = newNameMailbox.value;
    if (nameMailbox != null && nameMailbox.isNotEmpty) {
      final newMailboxArguments = NewMailboxArguments(
          MailboxName(nameMailbox),
          mailboxLocation: selectedMailbox.value);
      popBack(result: newMailboxArguments);
    }
  }

  void closeMailboxCreator(BuildContext context) {
    FocusScope.of(context).unfocus();
    popBack();
  }
}