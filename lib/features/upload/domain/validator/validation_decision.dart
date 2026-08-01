
sealed class ValidationDecision<Failure, Prompt> {
  const ValidationDecision();
}

final class ValidationAllowed<Failure, Prompt> extends ValidationDecision<Failure, Prompt> {
  const ValidationAllowed();
}

final class ValidationRejected<Failure, Prompt> extends ValidationDecision<Failure, Prompt> {
  final Failure failure;

  const ValidationRejected(this.failure);
}

final class ValidationConfirmationRequired<Failure, Prompt> extends ValidationDecision<Failure, Prompt> {
  final List<Prompt> prompts;

  ValidationConfirmationRequired(Iterable<Prompt> prompts) : prompts = List.unmodifiable(prompts);
}
