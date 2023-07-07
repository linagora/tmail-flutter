import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';

class StoreSpamReportStateLoading extends UIState {}

class StoreSpamReportStateSuccess extends UIState {
  final SpamReportState spamReportState;
  
  StoreSpamReportStateSuccess(this.spamReportState);

  @override
  List<Object> get props => [spamReportState];
}

class StoreSpamReportStateFailure extends FeatureFailure {

  StoreSpamReportStateFailure(dynamic exception) : super(exception: exception);
}