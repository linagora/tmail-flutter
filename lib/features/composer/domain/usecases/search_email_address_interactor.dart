import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/composer/domain/model/auto_complete_pattern.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/auto_complete_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_address_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/search_email_address_state.dart';

class SearchEmailAddressInteractor {
  final AutoCompleteRepository autoCompleteRepository;

  SearchEmailAddressInteractor(this.autoCompleteRepository);

  Future<Either<Failure, Success>> execute(AutoCompletePattern autoCompletePattern) async {
    try {
      final listEmailAddress = await autoCompleteRepository.getAutoComplete(autoCompletePattern);
      return Right(SearchEmailAddressSuccess(listEmailAddress));
    } catch (e) {
      return Left(SaveEmailAddressFailure(e));
    }
  }
}