import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/domain/repository/label_repository.dart';
import 'package:tmail_ui_user/features/labels/domain/state/delete_a_label_state.dart';

class DeleteALabelInteractor {
  final LabelRepository _labelRepository;

  DeleteALabelInteractor(this._labelRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    Label label,
  ) async* {
    try {
      yield Right(DeletingALabel());
      await _labelRepository.deleteLabel(accountId, label);
      yield Right(DeleteALabelSuccess(label));
    } catch (e) {
      yield Left(DeleteALabelFailure(e));
    }
  }
}
