import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';

class GettingLinagraEcosystem extends LoadingState {}

class GetLinagraEcosystemSuccess extends UIState {
  final LinagoraEcosystem linagoraEcosystem;

  GetLinagraEcosystemSuccess(this.linagoraEcosystem);

  @override
  List<Object> get props => [linagoraEcosystem];
}

class GetLinagraEcosystemFailure extends FeatureFailure {
  GetLinagraEcosystemFailure(dynamic exception) : super(exception: exception);
}
