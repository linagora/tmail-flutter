import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

class GetEmailByIdLoading extends LoadingState {}

class GetEmailByIdSuccess extends UIState {
  final PresentationEmail email;
  final PresentationMailbox? mailboxContain;
  final SearchQuery? searchQuery;

  GetEmailByIdSuccess(
    this.email,
    {
      this.mailboxContain,
      this.searchQuery,
    }
  );

  @override
  List<Object?> get props => [email, mailboxContain, searchQuery];
}

class GetEmailByIdFailure extends FeatureFailure {

  GetEmailByIdFailure(dynamic exception) : super(exception: exception);
}