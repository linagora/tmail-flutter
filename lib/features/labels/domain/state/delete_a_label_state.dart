import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DeletingALabel extends LoadingState {}

class DeleteALabelSuccess extends UIState {
  final String labelDisplayName;

  DeleteALabelSuccess(this.labelDisplayName);

  @override
  List<Object> get props => [labelDisplayName];
}

class DeleteALabelFailure extends FeatureFailure {
  DeleteALabelFailure(dynamic exception) : super(exception: exception);
}
