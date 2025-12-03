import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/company_server_login_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_company_server_login_info_state.dart';

class GetCompanyServerLoginInfoInteractor {
  final CompanyServerLoginRepository _serverLoginRepository;

  GetCompanyServerLoginInfoInteractor(this._serverLoginRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right(GettingCompanyServerLoginInfo());
      final serverLoginInfo =
          await _serverLoginRepository.getCompanyServerLoginInfo();
      yield Right(GetCompanyServerLoginInfoSuccess(serverLoginInfo));
    } catch (exception) {
      yield Left(GetCompanyServerLoginInfoFailure(exception));
    }
  }
}
