import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:labels/model/label.dart';

class CreatingNewLabel extends LoadingState {}

class CreateNewLabelSuccess extends UIState {
  final Label newLabel;

  CreateNewLabelSuccess(this.newLabel);

  @override
  List<Object> get props => [newLabel];
}

class CreateNewLabelFailure extends FeatureFailure {
  CreateNewLabelFailure(dynamic exception) : super(exception: exception);
}
