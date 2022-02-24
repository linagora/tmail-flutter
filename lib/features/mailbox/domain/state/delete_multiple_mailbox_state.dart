import 'package:core/core.dart';

class DeleteMultipleMailboxSuccess extends UIState {

  DeleteMultipleMailboxSuccess();

  @override
  List<Object?> get props => [];
}

class DeleteMultipleMailboxFailure extends FeatureFailure {
  final exception;

  DeleteMultipleMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}