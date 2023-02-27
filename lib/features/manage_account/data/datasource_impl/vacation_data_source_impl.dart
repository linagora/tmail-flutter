import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/vacation_data_source.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/vacation_api.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class VacationDataSourceImpl extends VacationDataSource {

  final VacationAPI _vacationAPI;
  final ExceptionThrower _exceptionThrower;

  VacationDataSourceImpl(this._vacationAPI, this._exceptionThrower);

  @override
  Future<List<VacationResponse>> getAllVacationResponse(AccountId accountId) {
    return Future.sync(() async {
      return await _vacationAPI.getAllVacationResponse(accountId);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<VacationResponse>> updateVacation(AccountId accountId, VacationResponse vacationResponse) {
    return Future.sync(() async {
      return await _vacationAPI.updateVacation(accountId, vacationResponse);
    }).catchError(_exceptionThrower.throwException);
  }
}