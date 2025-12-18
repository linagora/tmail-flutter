import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:scribe/scribe/ai/domain/model/ai_response.dart';

class GenerateAITextLoading extends LoadingState {}

class GenerateAITextSuccess extends UIState {
  final AIResponse response;

  GenerateAITextSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class GenerateAITextFailure extends FeatureFailure {
  GenerateAITextFailure(dynamic exception) : super(exception: exception);
}
