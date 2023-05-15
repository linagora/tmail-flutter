import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';

class GetOpenedEmailLoading extends UIState {}

class GetOpenedEmailSuccess extends UIState {
  final DetailedEmail detailedEmail;

  GetOpenedEmailSuccess(this.detailedEmail);

  @override
  List<Object?> get props => [detailedEmail];
}

class GetOpenedEmailFailure extends FeatureFailure {

  GetOpenedEmailFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}