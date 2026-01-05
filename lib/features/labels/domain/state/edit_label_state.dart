import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:labels/model/label.dart';

class EditingLabel extends LoadingState {}

class EditLabelSuccess extends UIState {
  final Label newLabel;

  EditLabelSuccess(this.newLabel);

  @override
  List<Object> get props => [newLabel];
}

class EditLabelFailure extends FeatureFailure {
  EditLabelFailure(dynamic exception) : super(exception: exception);
}
