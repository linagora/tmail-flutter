import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/update_vacation_state.dart';

class UpdateVacationInteractor {
  final ManageAccountRepository manageAccountRepository;

  UpdateVacationInteractor(this.manageAccountRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, VacationResponse vacationResponse) async* {
    try {
      yield Right<Failure, Success>(LoadingUpdateVacation());
      final listVacationResponse = await manageAccountRepository.updateVacation(accountId, vacationResponse);
      yield Right<Failure, Success>(UpdateVacationSuccess(listVacationResponse));
    } catch (exception) {
      yield Left<Failure, Success>(UpdateVacationFailure(exception));
    }
  }
}