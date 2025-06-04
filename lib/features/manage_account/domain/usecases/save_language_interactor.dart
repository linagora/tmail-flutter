import 'dart:core';
import 'dart:ui';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/preferences_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/save_language_state.dart';

class SaveLanguageInteractor {
  final PreferencesRepository manageAccountRepository;

  SaveLanguageInteractor(this.manageAccountRepository);

  Stream<Either<Failure, Success>> execute(Locale localeCurrent) async* {
    try {
      yield Right(SavingLanguage());
      await manageAccountRepository.persistLanguage(localeCurrent);
      yield Right(SaveLanguageSuccess(localeCurrent));
    } catch (exception) {
      yield Left(SaveLanguageFailure(exception));
    }
  }
}