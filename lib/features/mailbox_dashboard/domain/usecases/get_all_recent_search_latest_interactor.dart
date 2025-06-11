import 'dart:core';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/search_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_all_recent_search_latest_state.dart';

class GetAllRecentSearchLatestInteractor {
  final SearchRepository searchRepository;

  GetAllRecentSearchLatestInteractor(this.searchRepository);

  Future<Either<Failure, Success>> execute(
    AccountId accountId,
    UserName userName,
    {
      int? limit,
      String? pattern,
    }
  ) async {
    try {
      final listRecent = await searchRepository.getAllRecentSearchLatest(
        accountId,
        userName,
        limit: limit,
        pattern: pattern,
      );
      log('GetAllRecentSearchLatestInteractor::execute(): listRecent: ${listRecent.length}');
      return Right(GetAllRecentSearchLatestSuccess(listRecent));
    } catch (exception) {
      return Left(GetAllRecentSearchLatestFailure(exception));
    }
  }
}