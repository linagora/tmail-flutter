import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class EmptySpamFolderLoading extends LoadingState {}

class EmptySpamFolderSuccess extends UIState {

  final List<EmailId> emailIds;

  EmptySpamFolderSuccess(this.emailIds);

  @override
  List<Object?> get props => [emailIds];
}

class EmptySpamFolderFailure extends FeatureFailure {

  EmptySpamFolderFailure(dynamic exception) : super(exception: exception);
}