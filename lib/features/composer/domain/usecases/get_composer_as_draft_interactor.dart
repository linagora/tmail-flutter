import 'package:model/composer/composer.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';

class GetComposerAsDraftsInteractor {
  final ComposerRepository composerRepository;

  GetComposerAsDraftsInteractor(this.composerRepository);

  Future<Composer?> execute() async {
    try {
      return composerRepository.getDraftComposer();
    } catch (e) {
      return null;
    }
  }
}
