import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/model/company_server_login_info.dart';
import 'package:tmail_ui_user/features/login/domain/repository/company_server_login_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/save_company_server_login_info_state.dart';

class SaveCompanyServerLoginInfoInteractor {
  final CompanyServerLoginRepository _serverLoginRepository;

  SaveCompanyServerLoginInfoInteractor(this._serverLoginRepository);

  Stream<Either<Failure, Success>> execute(
    CompanyServerLoginInfo serverLoginInfo,
  ) async* {
    try {
      yield Right(SavingCompanyServerLoginInfo());
      await _serverLoginRepository.saveCompanyServerLoginInfo(serverLoginInfo);
      yield Right(SaveCompanyServerLoginInfoSuccess());
    } catch (exception) {
      yield Left(SaveCompanyServerLoginInfoFailure(exception));
    }
  }
}
