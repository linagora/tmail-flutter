
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/extensions/list_validator_extension.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/new_name_request.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';

class CompositeNameValidator extends Validator<NewNameRequest> {

  final List<Validator> _listValidator;

  CompositeNameValidator(this._listValidator);

  @override
  Either<Failure, Success> validate(NewNameRequest newNameRequest) {
    return _listValidator.isNotEmpty
      ? _listValidator.getValidatorNameViewState(newNameRequest)
      : Right<Failure, Success>(VerifyNameViewState());
  }
}