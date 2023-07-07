import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DeleteSendingEmailLoading extends UIState {}

class DeleteSendingEmailSuccess extends UIState {}

class DeleteSendingEmailFailure extends FeatureFailure {

  DeleteSendingEmailFailure(dynamic exception) : super(exception: exception);
}