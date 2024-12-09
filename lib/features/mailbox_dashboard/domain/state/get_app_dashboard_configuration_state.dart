import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/app_linagora_ecosystem.dart';

class LoadingAppDashboardConfiguration extends LoadingState {}

class GetAppDashboardConfigurationSuccess extends UIState {

  final List<AppLinagoraEcosystem> listLinagoraApp;

  GetAppDashboardConfigurationSuccess(this.listLinagoraApp);

  @override
  List<Object> get props => [listLinagoraApp];
}

class GetAppDashboardConfigurationFailure extends FeatureFailure {

  GetAppDashboardConfigurationFailure(dynamic exception) : super(exception: exception);
}