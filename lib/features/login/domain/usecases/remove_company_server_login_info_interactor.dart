import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/company_server_login_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/remove_company_server_login_info_state.dart';

class RemoveCompanyServerLoginInfoInteractor {
  final CompanyServerLoginRepository _serverLoginRepository;

  RemoveCompanyServerLoginInfoInteractor(this._serverLoginRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right(RemovingCompanyServerLoginInfo());
      await _serverLoginRepository.removeCompanyServerLoginInfo();
      yield Right(RemoveCompanyServerLoginInfoSuccess());
    } catch (exception) {
      yield Left(RemoveCompanyServerLoginInfoFailure(exception));
    }
  }
}
