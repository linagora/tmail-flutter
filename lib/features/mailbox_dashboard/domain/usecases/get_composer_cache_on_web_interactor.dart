import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_composer_cache_state.dart';

class GetComposerCacheOnWebInteractor {
  final ComposerCacheRepository composerCacheRepository;

  GetComposerCacheOnWebInteractor(this.composerCacheRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, UserName userName) async* {
    try {
      final listComposerCache = await composerCacheRepository.getComposerCacheOnWeb(
        accountId,
        userName,
      );
      yield Right(GetComposerCacheSuccess(listComposerCache));
    } catch (exception) {
      yield Left(GetComposerCacheFailure(exception));
    }
  }
}