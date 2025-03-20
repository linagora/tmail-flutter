import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/log_tracking.dart';

class GetTraceLogLoading extends LoadingState {}

class GetTraceLogSuccess extends UIState {
  final TraceLog traceLog;

  GetTraceLogSuccess(this.traceLog);

  @override
  List<Object?> get props => [traceLog];
}

class GetTraceLogFailure extends FeatureFailure {

  GetTraceLogFailure(dynamic exception) : super(exception: exception);
}