
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/new_name_request.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';

extension ListValidatorExtension on List<Validator> {
  Either<Failure, Success> getValidatorNameViewState(NewNameRequest newNameRequest) {
    for (var validator in this) {
      final either = validator.validate(newNameRequest);
      if (either.isLeft()) {
        return either;
      }
    }
    return Right<Failure, Success>(VerifyNameViewState());
  }
}