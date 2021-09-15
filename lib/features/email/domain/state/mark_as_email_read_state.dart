import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/read_actions.dart';

class MarkAsEmailReadSuccess extends UIState {
  final EmailId emailId;
  final ReadActions readActions;

  MarkAsEmailReadSuccess(this.emailId, this.readActions);

  @override
  List<Object?> get props => [emailId, readActions];
}

class MarkAsEmailReadFailure extends FeatureFailure {
  final exception;
  final ReadActions readActions;

  MarkAsEmailReadFailure(this.exception, this.readActions);

  @override
  List<Object> get props => [exception, readActions];
}