import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class UpdateEmailDraftsSuccess extends UIState {

  final Email emailAsDrafts;

  UpdateEmailDraftsSuccess(this.emailAsDrafts);

  @override
  List<Object?> get props => [];
}

class UpdateEmailDraftsFailure extends FeatureFailure {
  final dynamic exception;

  UpdateEmailDraftsFailure(this.exception);

  @override
  List<Object> get props => [exception];
}