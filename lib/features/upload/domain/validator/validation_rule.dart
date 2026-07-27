
import 'package:tmail_ui_user/features/upload/domain/validator/validation_decision.dart';

abstract interface class ValidationRule<Request, Failure, Prompt> {
  ValidationDecision<Failure, Prompt> validate(Request request);
}
