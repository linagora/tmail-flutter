
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_action.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/duplicate_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/special_character_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/mailbox_creator_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_logger.dart';

class MailboxCreatorController extends BaseController {

  final VerifyNameInteractor _verifyNameInteractor;

  final selectedMailbox = Rxn<PresentationMailbox>();
  final newNameMailbox = Rxn<String>();

  List<PresentationMailbox> allMailboxes = <PresentationMailbox>[];
  AccountId? accountId;

  MailboxCreatorController(
      this._verifyNameInteractor,
  );

  void setNewNameMailbox(String newName) => newNameMailbox.value = newName;

  @override
  void onReady() {
    super.onReady();
    final arguments = Get.arguments;
    if (arguments is MailboxCreatorArguments) {
      allMailboxes = arguments.allMailboxes;
      accountId = arguments.accountId;
      log('allMailboxes: $allMailboxes | accountId: $accountId');
    }
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
  }

  @override
  void onDone() {
  }

  @override
  void onError(error) {}

  bool isCreateMailboxValidated(BuildContext context) {
    final nameValidated = getErrorInputNameString(context);
    if (nameValidated?.isNotEmpty == true) {
      return false;
    }
    return true;
  }

  String? getErrorInputNameString(BuildContext context) {
    final nameMailbox = newNameMailbox.value;
    final listName = allMailboxes
        .where((mailbox) => !(mailbox.name.isBlank == true))
        .map((mailbox) => mailbox.name!.name).toList();

    return _verifyNameInteractor.execute(
        nameMailbox,
        [
          EmptyNameValidator(),
          DuplicateNameValidator(listName),
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
          arguments: DestinationPickerArguments(accountId!, MailboxAction.create)
      );
      if (destinationMailbox != null && destinationMailbox is PresentationMailbox) {
        selectedMailbox.value = destinationMailbox;
      }
    }
  }

  void closeMailboxCreator(BuildContext context) {
    FocusScope.of(context).unfocus();
    popBack();
  }
}