import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';

class MarkAsEmailImportantSuccess extends UIState {
  final EmailId emailId;
  final ImportantAction importantAction;

  MarkAsEmailImportantSuccess(this.emailId, this.importantAction);

  @override
  List<Object?> get props => [emailId, importantAction];
}

class MarkAsEmailImportantFailure extends FeatureFailure {
  final exception;
  final ImportantAction importantAction;

  MarkAsEmailImportantFailure(this.exception, this.importantAction);

  @override
  List<Object> get props => [exception, importantAction];
}