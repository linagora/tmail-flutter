
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/composite_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/new_name_request.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';

class VerifyNameInteractor {
  Either<Failure, Success> execute(String? newName, List<Validator> listValidator) {
    try {
      return CompositeNameValidator(listValidator).validate(NewNameRequest(newName));
    } catch (exception) {
      return Left<Failure, Success>(VerifyNameFailure(exception));
    }
  }
}