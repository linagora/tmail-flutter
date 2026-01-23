import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';

class GettingLinagoraEcosystem extends LoadingState {}

class GetLinagoraEcosystemSuccess extends UIState {
  final LinagoraEcosystem linagoraEcosystem;

  GetLinagoraEcosystemSuccess(this.linagoraEcosystem);

  @override
  List<Object> get props => [linagoraEcosystem];
}

class GetLinagoraEcosystemFailure extends FeatureFailure {
  GetLinagoraEcosystemFailure(dynamic exception) : super(exception: exception);
}
