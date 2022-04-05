import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

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
  List<Object> get props => [emailIds];
}

class DeleteMultipleEmailsPermanentlyAllFailure extends FeatureFailure {

  DeleteMultipleEmailsPermanentlyAllFailure();

  @override
  List<Object?> get props => [];
}

class DeleteMultipleEmailsPermanentlyFailure extends FeatureFailure {

  final exception;

  DeleteMultipleEmailsPermanentlyFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}