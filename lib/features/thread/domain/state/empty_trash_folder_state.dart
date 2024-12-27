import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class EmptyTrashFolderLoading extends LoadingState {}

class EmptyTrashFolderSuccess extends UIState {

  EmptyTrashFolderSuccess();

  @override
  List<Object?> get props => [];
}

class EmptyTrashFolderFailure extends FeatureFailure {

  EmptyTrashFolderFailure(dynamic exception) : super(exception: exception);
}

class CannotEmptyTrashException implements Exception {
  CannotEmptyTrashException();
}