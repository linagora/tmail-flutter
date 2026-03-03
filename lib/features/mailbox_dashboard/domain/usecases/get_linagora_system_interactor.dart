import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/linagora_ecosystem_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_linagora_ecosystem_state.dart';

class GetLinagoraEcosystemInteractor {
  final LinagoraEcosystemRepository _linagoraEcosystemRepository;

  GetLinagoraEcosystemInteractor(this._linagoraEcosystemRepository);

  Stream<Either<Failure, Success>> execute(String baseUrl) async* {
    try {
      final linagoraEcosystem = await _linagoraEcosystemRepository.getLinagoraEcosystem(baseUrl);

      yield Right(GetLinagoraEcosystemSuccess(linagoraEcosystem));
    } catch (e) {
      yield Left(GetLinagoraEcosystemFailure(e));
    }
  }
}