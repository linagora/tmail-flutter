import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class TransformHtmlSignatureLoading extends UIState {

  TransformHtmlSignatureLoading();

  @override
  List<Object?> get props => [];
}

class TransformHtmlSignatureSuccess extends UIState {
  final String signature;

  TransformHtmlSignatureSuccess(this.signature);

  @override
  List<Object?> get props => [signature];
}

class TransformHtmlSignatureFailure extends FeatureFailure {

  TransformHtmlSignatureFailure(exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}