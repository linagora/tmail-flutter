import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/app_grid_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_app_grid_linagora_ecosystem_state.dart';

class GetAppGridLinagraEcosystemInteractor {
  final AppGridRepository _appGridRepository;

  GetAppGridLinagraEcosystemInteractor(this._appGridRepository);

  Stream<Either<Failure, Success>> execute(String baseUrl) async* {
    try {
      yield Right(LoadingAppGridLinagraEcosystem());
      final linagoraEcosystem = await _appGridRepository.getLinagoraEcosystem(baseUrl);
      yield Right(GetAppGridLinagraEcosystemSuccess(linagoraEcosystem.listAppLinagoraEcosystem));
    } catch (e) {
      yield Left(GetAppGridLinagraEcosystemFailure(e));
    }
  }
}