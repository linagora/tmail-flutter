import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_label_setting_state.dart';

class GetLabelSettingStateInteractor {
  final ManageAccountRepository _manageAccountRepository;

  GetLabelSettingStateInteractor(this._manageAccountRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId) async* {
    try {
      yield Right(GettingLabelSettingState());
      final isEnabled = await _manageAccountRepository.getLabelSettingState();
      yield Right(GetLabelSettingStateSuccess(isEnabled, accountId));
    } catch (e) {
      yield Left(GetLabelSettingStateFailure(e));
    }
  }
}
