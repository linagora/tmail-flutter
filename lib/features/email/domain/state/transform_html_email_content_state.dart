import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class TransformHtmlEmailContentLoading extends LoadingState {}

class TransformHtmlEmailContentSuccess extends UIState {
  final String htmlContent;

  TransformHtmlEmailContentSuccess(this.htmlContent);

  @override
  List<Object?> get props => [htmlContent];
}

class TransformHtmlEmailContentFailure extends FeatureFailure {

  TransformHtmlEmailContentFailure(dynamic exception) : super(exception: exception);
}