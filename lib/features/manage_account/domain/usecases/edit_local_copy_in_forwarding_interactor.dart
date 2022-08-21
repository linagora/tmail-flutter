import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_local_copy_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_local_copy_in_forwarding_state.dart';

class EditLocalCopyInForwardingInteractor {
  final ManageAccountRepository manageAccountRepository;

  EditLocalCopyInForwardingInteractor(this.manageAccountRepository);

  Stream<Either<Failure, Success>> execute(
      AccountId accountId,
      EditLocalCopyInForwardingRequest editRequest,
  ) async* {
    try {
      final result = await manageAccountRepository.editLocalCopyInForwarding(
          accountId,
          editRequest);
      yield Right<Failure, Success>(EditLocalCopyInForwardingSuccess(result));
    } catch (exception) {
      yield Left<Failure, Success>(EditLocalCopyInForwardingFailure(exception));
    }
  }
}