import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class SaveEmailAsDraftsSuccess extends UIState {

  final Email emailAsDrafts;

  SaveEmailAsDraftsSuccess(this.emailAsDrafts);

  @override
  List<Object?> get props => [];
}

class SaveEmailAsDraftsFailure extends FeatureFailure {
  final dynamic exception;

  SaveEmailAsDraftsFailure(this.exception);

  @override
  List<Object> get props => [exception];
}