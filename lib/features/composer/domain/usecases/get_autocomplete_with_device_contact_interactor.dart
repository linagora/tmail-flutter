
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_device_contact_suggestions_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_device_contact_suggestions_interactor.dart';

class GetAutoCompleteWithDeviceContactInteractor {
  final GetAutoCompleteInteractor _getAutoCompleteInteractor;
  final GetDeviceContactSuggestionsInteractor _getDeviceContactSuggestionsInteractor;

  GetAutoCompleteWithDeviceContactInteractor(
      this._getAutoCompleteInteractor,
      this._getDeviceContactSuggestionsInteractor);

  Future<Either<Failure, Success>> execute(AutoCompletePattern autoCompletePattern) async {
    try {
      final resultExecutions = await Future.wait([
        _getAutoCompleteInteractor.execute(autoCompletePattern),
        _getDeviceContactSuggestionsInteractor.execute(autoCompletePattern)
      ]);

      final autoCompleteResults = resultExecutions.first.fold(
        (failure) => <EmailAddress>[],
        (success) => success is GetAutoCompleteSuccess ? success.listEmailAddress : <EmailAddress>[]);

      resultExecutions.last.map((success) {
          if (success is GetDeviceContactSuggestionsSuccess && success.results.isNotEmpty) {
            autoCompleteResults.addAll(success.results.map((contact) => contact.toEmailAddress()));
          }
        }
      );

      return Right<Failure, Success>(GetAutoCompleteSuccess(autoCompleteResults));
    } catch (exception) {
      return Left<Failure, Success>(GetAutoCompleteFailure(exception));
    }
  }
}