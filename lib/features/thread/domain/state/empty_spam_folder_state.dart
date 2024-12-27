import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class EmptySpamFolderLoading extends LoadingState {}

class EmptySpamFolderSuccess extends UIState {

  EmptySpamFolderSuccess();

  @override
  List<Object?> get props => [];
}

class EmptySpamFolderFailure extends FeatureFailure {

  EmptySpamFolderFailure(dynamic exception) : super(exception: exception);
}

class CannotEmptySpamFolderException implements Exception {
  CannotEmptySpamFolderException();
}