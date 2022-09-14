import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/vacation_data_source.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/vacation_repository.dart';

class VacationRepositoryImpl extends VacationRepository {
  final VacationDataSource dataSource;

  VacationRepositoryImpl(this.dataSource);

  @override
  Future<List<VacationResponse>> getAllVacationResponse(AccountId accountId) {
    return dataSource.getAllVacationResponse(accountId);
  }

  @override
  Future<List<VacationResponse>> updateVacation(AccountId accountId, VacationResponse vacationResponse) {
    return dataSource.updateVacation(accountId, vacationResponse);
  }
}