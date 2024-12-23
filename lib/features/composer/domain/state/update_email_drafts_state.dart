import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class UpdatingEmailDrafts extends LoadingState {}

class UpdateEmailDraftsSuccess extends UIState {

  final EmailId emailId;

  UpdateEmailDraftsSuccess(this.emailId);

  @override
  List<Object?> get props => [emailId, ...super.props];
}

class UpdateEmailDraftsFailure extends FeatureFailure {

  UpdateEmailDraftsFailure(dynamic exception) : super(exception: exception);
}