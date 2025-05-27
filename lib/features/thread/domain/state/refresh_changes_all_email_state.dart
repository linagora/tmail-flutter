import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';

class RefreshChangesAllEmailLoading extends LoadingState {}

class RefreshChangesAllEmailSuccess extends UIState {
  final List<PresentationEmail> emailList;
  final State? currentEmailState;
  final MailboxId? currentMailboxId;
  final EmailChangeResponse? emailChangeResponse;

  RefreshChangesAllEmailSuccess({
    required this.emailList,
    this.currentEmailState,
    this.currentMailboxId,
    this.emailChangeResponse,
  });

  @override
  List<Object?> get props => [
    emailList,
    currentEmailState,
    currentMailboxId,
    emailChangeResponse,
  ];
}

class RefreshChangesAllEmailFailure extends FeatureFailure {

  RefreshChangesAllEmailFailure(dynamic exception) : super(exception: exception);
}