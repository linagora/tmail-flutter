import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class EmptyTrashFolderLoading extends LoadingState {}

class EmptyTrashFolderSuccess extends UIState {

  final List<EmailId> emailIds;

  EmptyTrashFolderSuccess(this.emailIds);

  @override
  List<Object?> get props => [emailIds];
}

class EmptyTrashFolderFailure extends FeatureFailure {

  EmptyTrashFolderFailure(dynamic exception) : super(exception: exception);
}