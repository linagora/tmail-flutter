import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class ExportTraceLogLoading extends LoadingState {}

class ExportTraceLogSuccess extends UIState {

  String savePath;

  ExportTraceLogSuccess(this.savePath);

  @override
  List<Object?> get props => [savePath];
}

class ExportTraceLogFailure extends FeatureFailure {

  ExportTraceLogFailure(dynamic exception) : super(exception: exception);
}