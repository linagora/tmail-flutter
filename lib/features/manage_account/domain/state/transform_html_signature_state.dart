import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class TransformHtmlSignatureLoading extends UIState {}

class TransformHtmlSignatureSuccess extends UIState {
  final String signature;

  TransformHtmlSignatureSuccess(this.signature);

  @override
  List<Object?> get props => [signature];
}

class TransformHtmlSignatureFailure extends FeatureFailure {

  TransformHtmlSignatureFailure(exception) : super(exception: exception);
}