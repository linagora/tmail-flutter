import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GetNumberOfUnreadSpamEmailsLoading extends UIState {}

class GetNumberOfUnreadSpamEmailsSuccess extends UIState {
  final int unreadSpamEmailNumber;

  GetNumberOfUnreadSpamEmailsSuccess(this.unreadSpamEmailNumber);

  @override
  List<Object> get props => [unreadSpamEmailNumber];
}

class InvalidSpamReportCondition extends FeatureFailure {
  @override
  List<Object?> get props => [];
}

class GetNumberOfUnreadSpamEmailsFailure extends FeatureFailure {
  final dynamic exception;

  GetNumberOfUnreadSpamEmailsFailure(this.exception);

  @override
  List<Object> get props => [exception];
}