import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/local_email_draft.dart';

class GetAllLocalEmailDraftLoading extends LoadingState {}

class GetAllLocalEmailDraftSuccess extends UIState {

  final List<LocalEmailDraft> listLocalEmailDraft;

  GetAllLocalEmailDraftSuccess(this.listLocalEmailDraft);

  @override
  List<Object> get props => [listLocalEmailDraft];
}

class GetAllLocalEmailDraftFailure extends FeatureFailure {

  GetAllLocalEmailDraftFailure(dynamic exception) : super(exception: exception);
}