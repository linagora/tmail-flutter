import 'package:core/core.dart';
import 'package:model/model.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';

class GetEmailsInMailboxInteractor {
  final ThreadRepository threadRepository;

  GetEmailsInMailboxInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    {
      int? position,
      UnsignedInt? limit,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties
    }
  ) async* {
    try {
      yield Right<Failure, Success>(UIState.loading);
      final emailList = await threadRepository.getAllEmail(
        accountId,
        position: position,
        limit: limit,
        sort: sort,
        filter: filter,
        properties: properties
      );
      final presentationEmailList = emailList.map((email) => email.toPresentationEmail()).toList();
      yield Right<Failure, Success>(GetAllEmailSuccess(presentationEmailList));
    } catch (e) {
      yield Left(GetAllEmailFailure(e));
    }
  }
}