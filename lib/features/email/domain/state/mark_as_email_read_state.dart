import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class MarkAsEmailReadSuccess extends UIState {
  final EmailId emailId;

  MarkAsEmailReadSuccess(this.emailId);

  @override
  List<Object?> get props => [];
}

class MarkAsEmailReadFailure extends FeatureFailure {
  final exception;

  MarkAsEmailReadFailure(this.exception);

  @override
  List<Object> get props => [exception];
}