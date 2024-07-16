import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/personal_account_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/update_authentication_account_state.dart';

class UpdateAccountCacheInteractor {
  final AccountRepository _accountRepository;

  UpdateAccountCacheInteractor(this._accountRepository);

  Stream<Either<Failure, Success>> execute({required Session session, String? baseUrl}) async* {
    final apiUrl = _getQualifiedApiUrl(session: session, baseUrl: baseUrl);
    log('UpdateAccountCacheInteractor::execute: ApiUrl = $apiUrl');
    try{
      yield Right(UpdatingAccountCache());

      final currentAccount = await _accountRepository.getCurrentAccount();

      await _accountRepository.setCurrentAccount(
        currentAccount.fromAccount(
          accountId: session.accountId,
          apiUrl: apiUrl,
          userName: session.username
        ));

      yield Right(UpdateAccountCacheSuccess(
        session: session,
        apiUrl: apiUrl));
    } catch(e) {
      yield Left(UpdateAccountCacheFailure(
        session: session,
        apiUrl: apiUrl,
        exception: e
      ));
    }
  }

  String _getQualifiedApiUrl({required Session session, String? baseUrl}) {
    try {
      return session.getQualifiedApiUrl(baseUrl: baseUrl);
    } catch (e) {
      logError('UpdateAccountCacheInteractor::_getQualifiedApiUrl:Exception = $e');
      return '';
    }
  }
}