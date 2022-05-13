import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/autocomplete/auto_complete_pattern.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/auto_complete_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';

class GetAutoCompleteInteractor {
  final AutoCompleteRepository autoCompleteRepository;

  GetAutoCompleteInteractor(this.autoCompleteRepository);

  Future<Either<Failure, Success>> execute(AutoCompletePattern autoCompletePattern) async {
    try {
      final listEmailAddress = await autoCompleteRepository.getAutoComplete(autoCompletePattern);
      return Right(GetAutoCompleteSuccess(listEmailAddress));
    } catch (e) {
      return Left(GetAutoCompleteFailure(e));
    }
  }
}