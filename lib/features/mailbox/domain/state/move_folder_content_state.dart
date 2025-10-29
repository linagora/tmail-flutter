import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_folder_content_request.dart';

class MovingFolderContent extends LoadingState {}

class MoveFolderContentProgressState extends UIState {
  final MailboxId mailboxId;
  final int countEmailsCompleted;
  final int totalEmails;

  MoveFolderContentProgressState(
    this.mailboxId,
    this.countEmailsCompleted,
    this.totalEmails,
  );

  @override
  List<Object?> get props => [
        mailboxId,
        countEmailsCompleted,
        totalEmails,
      ];
}

class MoveFolderContentSuccess extends UIState {
  final MoveFolderContentRequest request;

  MoveFolderContentSuccess(this.request);

  @override
  List<Object?> get props => [request];
}

class MoveFolderContentFailure extends FeatureFailure {
  MoveFolderContentFailure(dynamic exception) : super(exception: exception);
}
