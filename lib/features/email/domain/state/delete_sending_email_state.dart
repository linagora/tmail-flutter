import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DeleteSendingEmailLoading extends UIState {}

class DeleteSendingEmailSuccess extends UIState {

  @override
  List<Object?> get props => [];
}

class DeleteSendingEmailFailure extends FeatureFailure {
  DeleteSendingEmailFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}