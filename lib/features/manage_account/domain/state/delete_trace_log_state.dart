import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DeleteTraceLogLoading extends LoadingState {}

class DeleteTraceLogSuccess extends UIState {}

class DeleteTraceLogFailure extends FeatureFailure {

  DeleteTraceLogFailure(dynamic exception) : super(exception: exception);
}