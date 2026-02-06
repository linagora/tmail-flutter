import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:labels/model/label.dart';

class DeletingALabel extends LoadingState {}

class DeleteALabelSuccess extends UIState {
  final Label deletedLabel;

  DeleteALabelSuccess(this.deletedLabel);

  @override
  List<Object> get props => [deletedLabel];
}

class DeleteALabelFailure extends FeatureFailure {
  DeleteALabelFailure(dynamic exception) : super(exception: exception);
}
