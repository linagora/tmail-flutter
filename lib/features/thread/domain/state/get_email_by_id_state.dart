import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';

class GetEmailByIdLoading extends LoadingState {}

class GetEmailByIdSuccess extends UIState {
  final PresentationEmail email;
  final MailboxId? mailboxId;
  final DashboardType dashboardType;

  GetEmailByIdSuccess(this.email, this.mailboxId, this.dashboardType);

  @override
  List<Object?> get props => [email, mailboxId, dashboardType];
}

class GetEmailByIdFailure extends FeatureFailure {
  final dynamic exception;

  GetEmailByIdFailure(this.exception);

  @override
  List<Object> get props => [exception];
}