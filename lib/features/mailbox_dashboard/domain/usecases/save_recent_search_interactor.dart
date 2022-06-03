import 'dart:core';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/search_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/save_recent_search_state.dart';

class SaveRecentSearchInteractor {
  final SearchRepository searchRepository;

  SaveRecentSearchInteractor(this.searchRepository);

  Stream<Either<Failure, Success>> execute(RecentSearch recentSearch) async* {
    try {
      await searchRepository.saveRecentSearch(recentSearch);
      yield Right(SaveRecentSearchSuccess());
    } catch (exception) {
      yield Left(SaveRecentSearchFailure(exception));
    }
  }
}