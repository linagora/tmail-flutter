
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/exceptions/verify_name_exception.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/new_name_request.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';

class NameWithSpaceOnlyValidator extends Validator<NewNameRequest> {

  @override
  Either<Failure, Success> validate(NewNameRequest value) {
    if (value.value != null && value.value!.isNotEmpty && value.value!.trim().isEmpty) {
      return Left<Failure, Success>(VerifyNameFailure(const NameWithSpaceOnlyException()));
    } else {
      return Right<Failure, Success>(VerifyNameViewState());
    }
  }
}