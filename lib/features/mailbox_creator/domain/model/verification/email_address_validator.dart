
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/exceptions/verify_name_exception.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/new_name_request.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';

class EmailAddressValidator extends Validator<NewNameRequest> {

  @override
  Either<Failure, Success> validate(NewNameRequest newNameRequest) {
    if (newNameRequest.value != null && GetUtils.isEmail(newNameRequest.value!)) {
      return Right<Failure, Success>(VerifyNameViewState());
    } else {
      return Left<Failure, Success>(VerifyNameFailure(const EmailAddressInvalidException()));
    }
  }
}