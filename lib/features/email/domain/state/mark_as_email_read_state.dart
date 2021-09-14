import 'package:core/core.dart';

class MarkAsEmailReadSuccess extends UIState {

  MarkAsEmailReadSuccess();

  @override
  List<Object?> get props => [];
}

class MarkAsEmailReadFailure extends FeatureFailure {
  final exception;

  MarkAsEmailReadFailure(this.exception);

  @override
  List<Object> get props => [exception];
}