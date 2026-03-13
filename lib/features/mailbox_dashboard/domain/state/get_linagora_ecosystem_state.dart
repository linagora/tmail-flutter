import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';

class GetLinagoraEcosystemSuccess extends Success {
  final LinagoraEcosystem linagoraEcosystem;

  GetLinagoraEcosystemSuccess(this.linagoraEcosystem);

  @override
  List<Object?> get props => [linagoraEcosystem];
}

class GetLinagoraEcosystemFailure extends Failure {
  final dynamic exception;

  GetLinagoraEcosystemFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}