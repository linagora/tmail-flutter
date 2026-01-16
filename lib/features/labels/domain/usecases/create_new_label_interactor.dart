import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/domain/repository/label_repository.dart';
import 'package:tmail_ui_user/features/labels/domain/state/create_new_label_state.dart';

class CreateNewLabelInteractor {
  final LabelRepository _labelRepository;

  CreateNewLabelInteractor(this._labelRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    Label labelData,
  ) async* {
    try {
      yield Right(CreatingNewLabel());
      final newLabel = await _labelRepository.createNewLabel(
        accountId,
        labelData,
      );
      yield Right(CreateNewLabelSuccess(newLabel));
    } catch (e) {
      yield Left(CreateNewLabelFailure(e));
    }
  }
}
