import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';

class StoreSpamReportStateLoading extends UIState {}

class StoreSpamReportStateSuccess extends UIState {
  final SpamReportState spamReportState;
  
  StoreSpamReportStateSuccess(this.spamReportState);

  @override
  List<Object> get props => [];
}

class StoreSpamReportStateFailure extends FeatureFailure {
  final dynamic exception;

  StoreSpamReportStateFailure(this.exception);

  @override
  List<Object> get props => [exception];
}