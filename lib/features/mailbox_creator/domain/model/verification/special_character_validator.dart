
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/exceptions/verify_name_exception.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/extensions/name_validator_string_extension.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/new_name_request.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';

class SpecialCharacterValidator extends Validator<NewNameRequest> {

  @override
  Either<Failure, Success> validate(NewNameRequest value) {
    if (value.value != null && value.value!.hasSpecialCharactersInName()) {
      return Left<Failure, Success>(VerifyNameFailure(const SpecialCharacterException()));
    } else {
      return Right<Failure, Success>(VerifyNameViewState());
    }
  }
}