import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_address_state.dart';

class SaveEmailAddressesInteractor {
  final ComposerRepository composerRepository;

  SaveEmailAddressesInteractor(this.composerRepository);

  Future<Either<Failure, Success>> execute(List<EmailAddress> emailAddress) async {
    try {
      final result = await composerRepository.saveEmailAddresses(emailAddress);
      return result ? Right(SaveEmailAddressSuccess()) : Left(SaveEmailAddressFailure(result));
    } catch (e) {
      return Left(SaveEmailAddressFailure(e));
    }
  }
}