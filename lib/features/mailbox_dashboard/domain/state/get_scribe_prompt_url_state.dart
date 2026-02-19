import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/state/failure.dart';

class GetScribePromptUrlSuccess extends Success {
  final String? promptUrl;

  GetScribePromptUrlSuccess(this.promptUrl);

  @override
  List<Object?> get props => [promptUrl];
}

class GetScribePromptUrlFailure extends Failure {
  final dynamic exception;

  GetScribePromptUrlFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}