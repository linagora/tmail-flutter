import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:labels/model/label.dart';

class GettingAllLabel extends LoadingState {}

class GetAllLabelSuccess extends UIState {
  final List<Label> labels;

  GetAllLabelSuccess(this.labels);

  @override
  List<Object> get props => [labels];
}

class GetAllLabelFailure extends FeatureFailure {
  GetAllLabelFailure(dynamic exception) : super(exception: exception);
}
