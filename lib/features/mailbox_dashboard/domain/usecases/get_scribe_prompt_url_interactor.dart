import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/linagora_ecosystem_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_scribe_prompt_url_state.dart';

class GetScribePromptUrlInteractor {
  final LinagoraEcosystemRepository _linagoraEcosystemRepository;

  GetScribePromptUrlInteractor(this._linagoraEcosystemRepository);

  Stream<Either<Failure, Success>> execute(String baseUrl) async* {
    try {
      final promptUrl = await _linagoraEcosystemRepository.getScribePromptUrl(baseUrl);

      yield Right(GetScribePromptUrlSuccess(promptUrl));
    } catch (e) {
      yield Left(GetScribePromptUrlFailure(e));
    }
  }
}