
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:model/autocomplete/auto_complete_pattern.dart';
import 'package:model/contact/contact.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/contact_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_device_contact_suggestions_state.dart';

class GetDeviceContactSuggestionsInteractor {
  final ContactRepository _contactRepository;

  GetDeviceContactSuggestionsInteractor(this._contactRepository);

  Future<Either<Failure, Success>> execute(AutoCompletePattern autoCompletePattern) async {
    try {
      final resultList = await _contactRepository.getContactSuggestions(autoCompletePattern);
      final listEmailAddress = resultList.map((contact) => contact.toEmailAddress()).toList();
      log('GetDeviceContactSuggestionsInteractor::execute:listEmailAddress: $listEmailAddress');
      return Right<Failure, Success>(GetDeviceContactSuggestionsSuccess(listEmailAddress));
    } catch (exception) {
      return Left<Failure, Success>(GetDeviceContactSuggestionsFailure(exception));
    }
  }
}