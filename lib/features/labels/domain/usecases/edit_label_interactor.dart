import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/labels/domain/model/edit_label_request.dart';
import 'package:tmail_ui_user/features/labels/domain/repository/label_repository.dart';
import 'package:tmail_ui_user/features/labels/domain/state/edit_label_state.dart';

class EditLabelInteractor {
  final LabelRepository _labelRepository;

  EditLabelInteractor(this._labelRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    EditLabelRequest labelRequest,
  ) async* {
    try {
      yield Right(EditingLabel());
      final newLabel = await _labelRepository.editLabel(
        accountId,
        labelRequest,
      );
      yield Right(EditLabelSuccess(newLabel));
    } catch (e) {
      yield Left(EditLabelFailure(e));
    }
  }
}
