
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
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
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class MailboxCreatorController extends BaseController {

  final VerifyNameInteractor _verifyNameInteractor;

  final selectedMailbox = Rxn<PresentationMailbox>();
  final newNameMailbox = Rxn<String>();
  bool _createdMailbox = false;

  final FocusNode nameInputFocusNode = FocusNode();
  final TextEditingController nameInputController = TextEditingController();

  MailboxCreatorArguments? arguments;
  AccountId? accountId;
  Session? _session;
  MailboxTree? defaultMailboxTree;
  MailboxTree? personalMailboxTree;
  MailboxTree? teamMailboxesTre;

  List<String> listMailboxNameAsStringExist = <String>[];

  MailboxCreatorController(this._verifyNameInteractor);

  void setNewNameMailbox(String newName) => newNameMailbox.value = newName;

  @override
  void onInit() {
    super.onInit();
    log('MailboxCreatorController::onInit():arguments: ${Get.arguments}');
    arguments = Get.arguments;
  }

  @override
  void onReady() {
    super.onReady();
    log('MailboxCreatorController::onReady():');
    if (arguments != null) {
      personalMailboxTree = arguments!.personalMailboxTree;
      defaultMailboxTree = arguments!.defaultMailboxTree;
      teamMailboxesTre = arguments!.teamMailboxesTree;
      accountId = arguments!.accountId;
      _session = arguments!.session;
      if (arguments!.selectedMailbox != null) {
        selectedMailbox.value = arguments!.selectedMailbox;
      }
      _createListMailboxNameAsStringInMailboxLocation();
    }
  }

  @override
  void onClose() {
    log('MailboxCreatorController::onClose():');
    nameInputFocusNode.dispose();
    nameInputController.dispose();
    super.onClose();
  }

  MailboxNode? _findMailboxNodeById(MailboxId mailboxId) {
    final mailboxNode = defaultMailboxTree?.findNode((node) => node.item.id == mailboxId)
     ?? personalMailboxTree?.findNode((node) => node.item.id == mailboxId)
     ?? teamMailboxesTre?.findNode((node) => node.item.id == mailboxId);
    return mailboxNode;
  }

  void _createListMailboxNameAsStringInMailboxLocation() {
    if (selectedMailbox.value == null) {
      final allChildrenAtMailboxLocation = (defaultMailboxTree?.root.childrenItems ?? <MailboxNode>[]) 
        + (personalMailboxTree?.root.childrenItems ?? <MailboxNode>[])
        + (teamMailboxesTre?.root.childrenItems ?? <MailboxNode>[]);
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

  void selectMailboxLocation(BuildContext context) async {
    KeyboardUtils.hideKeyboard(context);

    if (accountId != null) {
      final arguments = DestinationPickerArguments(
        accountId!,
        MailboxActions.create,
        _session,
        mailboxIdSelected: selectedMailbox.value?.id);

      final destinationMailbox = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.destinationPicker, arguments: arguments)
        : await push(AppRoutes.destinationPicker, arguments: arguments);

      if (destinationMailbox is PresentationMailbox) {
        final mailboxDestination = destinationMailbox == PresentationMailbox.unifiedMailbox
          ? null
          : destinationMailbox;

        selectedMailbox.value = mailboxDestination;
        _createListMailboxNameAsStringInMailboxLocation();
      }
    }
  }

  void createNewMailbox(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);

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
    }
  }

  void closeMailboxCreator(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);
    popBack();
  }
}