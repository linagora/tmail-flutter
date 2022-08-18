import 'dart:core';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_forward_state.dart';

class GetForwardInteractor {
  final ManageAccountRepository manageAccountRepository;

  GetForwardInteractor(this.manageAccountRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId) async* {
    try {
      yield Right<Failure, Success>(LoadingState());
      final response = await manageAccountRepository.getForward(accountId);
      yield Right(GetForwardSuccess(response));
    } catch (exception) {
      yield Left(GetForwardFailure(exception));
    }
  }
}