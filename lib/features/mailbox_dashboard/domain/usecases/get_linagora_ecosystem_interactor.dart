import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/linagora_ecosystem_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_linagora_ecosystem_state.dart';

class GetLinagoraEcosystemInteractor {
  final LinagoraEcosystemRepository _ecosystemRepository;

  GetLinagoraEcosystemInteractor(this._ecosystemRepository);

  Stream<Either<Failure, Success>> execute(String baseUrl) async* {
    try {
      yield Right(GettingLinagraEcosystem());
      final linagoraEcosystem =
          await _ecosystemRepository.getLinagoraEcosystem(baseUrl);
      yield Right(GetLinagraEcosystemSuccess(linagoraEcosystem));
    } catch (e) {
      yield Left(GetLinagraEcosystemFailure(e));
    }
  }
}
