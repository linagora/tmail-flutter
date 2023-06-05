
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DeleteMultipleSendingEmailLoading extends UIState {}

class DeleteMultipleSendingEmailAllSuccess extends UIState {}

class DeleteMultipleSendingEmailHasSomeSuccess extends UIState {}

class DeleteMultipleSendingEmailAllFailure extends FeatureFailure {

  DeleteMultipleSendingEmailAllFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}

class DeleteMultipleSendingEmailFailure extends FeatureFailure {

  DeleteMultipleSendingEmailFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}