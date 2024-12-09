import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/app_linagora_ecosystem.dart';
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
      List<AppLinagoraEcosystem> listMobileAppLinagora = linagoraEcosystem.listAppLinagoraEcosystem;
      if (PlatformInfo.isAndroid) {
        listMobileAppLinagora = linagoraEcosystem.listAppLinagoraEcosystemOnAndroid;
      } else if (PlatformInfo.isIOS) {
        listMobileAppLinagora = linagoraEcosystem.listAppLinagoraEcosystemOnIOS;
      }
      yield Right(GetAppGridLinagraEcosystemSuccess(listMobileAppLinagora));
    } catch (e) {
      yield Left(GetAppGridLinagraEcosystemFailure(e));
    }
  }
}