import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/app_dashboard/linagora_applications.dart';

class LoadingAppDashboardConfiguration extends UIState {}

class GetAppDashboardConfigurationSuccess extends UIState {

  final LinagoraApplications linagoraApplications;

  GetAppDashboardConfigurationSuccess(this.linagoraApplications);

  @override
  List<Object> get props => [linagoraApplications];
}

class GetAppDashboardConfigurationFailure extends FeatureFailure {
  final dynamic exception;

  GetAppDashboardConfigurationFailure(this.exception);

  @override
  List<Object> get props => [exception];
}