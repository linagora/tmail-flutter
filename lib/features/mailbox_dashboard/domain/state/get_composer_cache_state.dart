import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/local_email_draft.dart';

class GetLocalEmailDraftSuccess extends UIState {

  final List<LocalEmailDraft> listLocalEmailDraft;

  GetLocalEmailDraftSuccess(this.listLocalEmailDraft);

  @override
  List<Object> get props => [listLocalEmailDraft];
}

class GetLocalEmailDraftFailure extends FeatureFailure {

  GetLocalEmailDraftFailure(dynamic exception) : super(exception: exception);
}