import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/model.dart';

class MarkAsEmailReadSuccess extends UIState {
  final Email updatedEmail;
  final ReadActions readActions;

  MarkAsEmailReadSuccess(this.updatedEmail, this.readActions);

  @override
  List<Object?> get props => [updatedEmail, readActions];
}

class MarkAsEmailReadFailure extends FeatureFailure {
  final exception;
  final ReadActions readActions;

  MarkAsEmailReadFailure(this.exception, this.readActions);

  @override
  List<Object> get props => [exception, readActions];
}