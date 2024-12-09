import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/app_linagora_ecosystem.dart';

class LoadingAppGridLinagraEcosystem extends LoadingState {}

class GetAppGridLinagraEcosystemSuccess extends UIState {

  final List<AppLinagoraEcosystem> listAppLinagoraEcosystem;

  GetAppGridLinagraEcosystemSuccess(this.listAppLinagoraEcosystem);

  @override
  List<Object> get props => [listAppLinagoraEcosystem];
}

class GetAppGridLinagraEcosystemFailure extends FeatureFailure {

  GetAppGridLinagraEcosystemFailure(dynamic exception) : super(exception: exception);
}