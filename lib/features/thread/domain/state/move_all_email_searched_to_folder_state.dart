import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class MoveAllEmailSearchedToFolderLoading extends LoadingState {}

class MoveAllEmailSearchedToFolderSuccess extends UIState {
  final List<EmailId> listEmailId;
  final String destinationPath;

  MoveAllEmailSearchedToFolderSuccess(this.listEmailId, this.destinationPath);

  @override
  List<Object> get props => [listEmailId, destinationPath];
}

class MoveAllEmailSearchedToFolderFailure extends FeatureFailure {
  final String destinationPath;

  MoveAllEmailSearchedToFolderFailure(
    this.destinationPath,
    dynamic exception,
  ) : super(exception: exception);

  @override
  List<Object?> get props => [destinationPath, ...super.props];
}