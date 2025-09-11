import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';

abstract class AibotRepository {
  Future<Either<Failure, String>> suggestReply({
    required AccountId accountId,
    required String emailId,
    required String userInput,
  });
}
