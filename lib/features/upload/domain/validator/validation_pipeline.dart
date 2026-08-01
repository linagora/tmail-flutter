
import 'package:tmail_ui_user/features/upload/domain/validator/validation_decision.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/validation_rule.dart';

final class ValidationPipeline<Request, Failure, Prompt> {
  final List<ValidationRule<Request, Failure, Prompt>> _rules;

  ValidationPipeline(Iterable<ValidationRule<Request, Failure, Prompt>> rules)
      : _rules = List.unmodifiable(rules);

  ValidationDecision<Failure, Prompt> validate(Request request) {
    final prompts = <Prompt>[];
    for (final rule in _rules) {
      switch (rule.validate(request)) {
        case ValidationAllowed():
          break;
        case ValidationRejected(:final failure):
          return ValidationRejected(failure);
        case ValidationConfirmationRequired(prompts: final rulePrompts):
          prompts.addAll(rulePrompts);
      }
    }
    return prompts.isEmpty
        ? const ValidationAllowed()
        : ValidationConfirmationRequired(prompts);
  }
}
