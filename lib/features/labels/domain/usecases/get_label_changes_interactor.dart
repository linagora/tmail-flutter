import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:tmail_ui_user/features/labels/domain/repository/label_repository.dart';
import 'package:tmail_ui_user/features/labels/domain/state/get_label_changes_state.dart';

class GetLabelChangesInteractor {
  final LabelRepository _labelRepository;

  GetLabelChangesInteractor(this._labelRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    State sinceState,
  ) async* {
    try {
      yield Right(GettingLabelChanges());
      final changesResult = await _labelRepository.getLabelChanges(
        session,
        accountId,
        sinceState,
      );
      yield Right(GetLabelChangesSuccess(changesResult));
    } catch (e) {
      yield Left(GetLabelChangesFailure(e));
    }
  }
}
