import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class LoadingDeleteMultipleEmailsPermanentlyAll extends UIState {}

class DeleteMultipleEmailsPermanentlyAllSuccess extends UIState {

  List<EmailId> emailIds;

  DeleteMultipleEmailsPermanentlyAllSuccess(this.emailIds);

  @override
  List<Object?> get props => [emailIds];
}

class DeleteMultipleEmailsPermanentlyHasSomeEmailFailure extends UIState {

  List<EmailId> emailIds;

  DeleteMultipleEmailsPermanentlyHasSomeEmailFailure(this.emailIds);

  @override
  List<Object?> get props => [emailIds];
}

class DeleteMultipleEmailsPermanentlyAllFailure extends FeatureFailure {}

class DeleteMultipleEmailsPermanentlyFailure extends FeatureFailure {

  DeleteMultipleEmailsPermanentlyFailure(dynamic exception) : super(exception: exception);
}