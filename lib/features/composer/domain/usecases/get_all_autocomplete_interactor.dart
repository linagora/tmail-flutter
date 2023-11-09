
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/autocomplete/auto_complete_pattern.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_device_contact_suggestions_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_device_contact_suggestions_interactor.dart';

class GetAllAutoCompleteInteractor {
  final GetAutoCompleteInteractor _getAutoCompleteInteractor;
  final GetDeviceContactSuggestionsInteractor _getDeviceContactSuggestionsInteractor;

  GetAllAutoCompleteInteractor(
    this._getAutoCompleteInteractor,
    this._getDeviceContactSuggestionsInteractor
  );

  Future<Either<Failure, Success>> execute(AutoCompletePattern autoCompletePattern) async {
    try {
      final resultExecutions = await Future.wait([
        _getAutoCompleteInteractor.execute(autoCompletePattern),
        _getDeviceContactSuggestionsInteractor.execute(autoCompletePattern)
      ]);

      final autoCompleteResults = List<EmailAddress>.empty(growable: true);

      final listEmailAddressFromServer = resultExecutions[0].fold(
        (failure) => <EmailAddress>[],
        (success) => success is GetAutoCompleteSuccess
          ? success.listEmailAddress
          : <EmailAddress>[]
      );
      log('GetAllAutoCompleteInteractor::execute:listEmailAddressFromServer: $listEmailAddressFromServer');
      autoCompleteResults.addAll(listEmailAddressFromServer);

      final listEmailAddressFromDevice = resultExecutions[1].fold(
        (failure) => <EmailAddress>[],
        (success) => success is GetDeviceContactSuggestionsSuccess
          ? success.listEmailAddress
          : <EmailAddress>[]
      );
      log('GetAllAutoCompleteInteractor::execute:listEmailAddressFromDevice: $listEmailAddressFromDevice');
      autoCompleteResults.addAll(listEmailAddressFromDevice);

      return Right<Failure, Success>(GetAutoCompleteSuccess(autoCompleteResults));
    } catch (exception) {
      return Left<Failure, Success>(GetAutoCompleteFailure(exception));
    }
  }
}