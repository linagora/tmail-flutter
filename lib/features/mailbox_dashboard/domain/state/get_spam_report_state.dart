import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';

class GetSpamReportStateLoading extends UIState {}

class GetSpamReportStateSuccess extends UIState {
  final SpamReportState spamReportState;

  GetSpamReportStateSuccess(this.spamReportState);

  @override
  List<Object> get props => [spamReportState];
}

class GetSpamReportStateFailure extends FeatureFailure {

  GetSpamReportStateFailure(dynamic exception) : super(exception: exception);
}