import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/labels/domain/repository/label_repository.dart';
import 'package:tmail_ui_user/features/labels/domain/state/get_all_label_state.dart';

class GetAllLabelInteractor {
  final LabelRepository _labelRepository;

  GetAllLabelInteractor(this._labelRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId) async* {
    try {
      yield Right(GettingAllLabel());
      final result = await _labelRepository.getAllLabels(accountId);
      yield Right(GetAllLabelSuccess(result.labels, result.newState));
    } catch (e) {
      yield Left(GetAllLabelFailure(e));
    }
  }
}
