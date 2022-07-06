import 'package:model/composer/composer.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';

class SaveComposerAsDraftsInteractor {
  final ComposerRepository composerRepository;

  SaveComposerAsDraftsInteractor(this.composerRepository);

  Future<void> execute(Composer composer) async {
    return composerRepository.setDraftComposer(composer);
  }
}
