import 'dart:core';
import 'dart:ui';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/save_language_app_state.dart';

class SaveLanguageAppInteractor {
  final ManageAccountRepository manageAccountRepository;

  SaveLanguageAppInteractor(this.manageAccountRepository);

  Stream<Either<Failure, Success>> execute(Locale localeCurrent) async* {
    try {
      yield Right(SavingLanguageApp());
      await manageAccountRepository.persistLanguage(localeCurrent);
      yield Right(SaveLanguageAppSuccess());
    } catch (exception) {
      yield Left(SaveLanguageAppFailure(exception));
    }
  }
}