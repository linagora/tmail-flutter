import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';

abstract class VacationDataSource {
  Future<List<VacationResponse>> getAllVacationResponse(AccountId accountId);

  Future<List<VacationResponse>> updateVacation(AccountId accountId, VacationResponse vacationResponse);
}