import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/forwarding_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_forward_state.dart';

class GetForwardInteractor {
  final ForwardingRepository _forwardingRepository;

  GetForwardInteractor(this._forwardingRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId) async* {
    try {
      yield Right<Failure, Success>(LoadingState());
      final response = await _forwardingRepository.getForward(accountId);
      yield Right(GetForwardSuccess(response));
    } catch (exception) {
      yield Left(GetForwardFailure(exception));
    }
  }
}