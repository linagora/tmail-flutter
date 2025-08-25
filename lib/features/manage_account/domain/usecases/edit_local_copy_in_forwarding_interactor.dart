import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_local_copy_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/forwarding_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_local_copy_in_forwarding_state.dart';

class EditLocalCopyInForwardingInteractor {
  final ForwardingRepository _forwardingRepository;

  EditLocalCopyInForwardingInteractor(this._forwardingRepository);

  Stream<Either<Failure, Success>> execute(
      AccountId accountId,
      EditLocalCopyInForwardingRequest editRequest,
  ) async* {
    try {
      final result = await _forwardingRepository.editLocalCopyInForwarding(
        accountId,
        editRequest,
      );

      if (result.$2 == null) {
        yield Right(EditLocalCopyInForwardingSuccess(result.$1));
      } else {
        yield Left(EditLocalCopyInForwardingSuccessWithSomeCaseFailure(
          result.$1,
          result.$2!,
        ));
      }
    } catch (exception) {
      yield Left<Failure, Success>(EditLocalCopyInForwardingFailure(exception));
    }
  }
}