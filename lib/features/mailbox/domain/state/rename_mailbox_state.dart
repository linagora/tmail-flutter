import 'package:core/core.dart';

class RenameMailboxSuccess extends UIState {

  RenameMailboxSuccess();

  @override
  List<Object?> get props => [];
}

class RenameMailboxFailure extends FeatureFailure {
  final dynamic exception;

  RenameMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}