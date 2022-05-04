import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/exceptions/verify_name_exception.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/new_name_request.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';

class DuplicateNameValidator extends Validator<NewNameRequest> {
  final List<String> _listName;

  DuplicateNameValidator(this._listName);

  @override
  Either<Failure, Success> validate(NewNameRequest newNameRequest) {
    if (newNameRequest.value != null) {
      final nameExist = _listName
          .map((nameItem) => nameItem.toLowerCase())
          .contains(newNameRequest.value!.toLowerCase());
      if (nameExist) {
        return Left<Failure, Success>(VerifyNameFailure(const DuplicatedNameException()));
      } else {
        return Right<Failure, Success>(VerifyNameViewState());
      }
    } else {
      return Right<Failure, Success>(VerifyNameViewState());
    }
  }
}