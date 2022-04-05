import 'package:core/core.dart';

class EmptyTrashFolderSuccess extends UIState {

  EmptyTrashFolderSuccess();

  @override
  List<Object?> get props => [];
}

class EmptyTrashFolderFailure extends FeatureFailure {
  final exception;

  EmptyTrashFolderFailure(this.exception);

  @override
  List<Object> get props => [exception];
}